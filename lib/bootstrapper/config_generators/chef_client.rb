require 'chef/rest'
require 'bootstrapper/config_generator'
module Bootstrapper
  module ConfigGenerators

    # == Bootstrapper::ChefClient
    # Manages a collection of file descriptions to be installed on the remote
    # node, and installs them via scp+ssh.
    #
    # Files are installed in a two stage process. First, files are staged to a
    # staging directory in /tmp, then they are moved to the final location in
    # /etc/chef.
    class ChefClient < ConfigGenerator

      short_name(:chef_client)

      # TODO: extract code to here from base as necessary

      def prepare
        sanity_check

        create_client
        create_node
      end

      # Name for the client/node pair to be created
      # TODO: Should get this from FQDN or -N option, timestamp works for testing purposes.
      def entity_name
        @entity_name ||= Time.new.strftime("%Y-%M-%d-%H-%M-%S")
      end


      ############################################################
      # Chef Client resource creation
      #
      # Sanity checks node and client existence on the server,
      # creates client and node in a way that will make authz happy.
      ############################################################

      def chef_api
        Chef::REST.new(Chef::Config[:chef_server_url])
      end

      def sanity_check
        if resource_exists?("nodes/#{entity_name}")
          ui.confirm("Node #{entity_name} exists, overwrite it?")
          # Must delete, as the client created later may not be able to overwrite it.
          chef_api.delete("nodes/#{entity_name}")
        end
        if resource_exists?("clients/#{entity_name}")
          ui.config("Client #{entity_name} exists, overwrite it?")
          chef_api.delete("client/#{entity_name}")
        end

      end

      def resource_exists?(relative_path)
        chef_api.get(relative_path)
        true
      rescue Net::HTTPServerException => e
        if e.response.code == "404"
          false
        else
          raise
        end
      end

      def create_client
        return @client unless @client.nil?
        api_response = chef_api.post('clients', :name => entity_name, :admin => false)
        @client = Chef::ApiClient.new.tap do |c|
          c.name entity_name
          c.admin false
          c.private_key api_response['private_key']
        end
        ui.msg "Created client '#{@client.name}'"

        config_installer.install_file("client key", "client.pem") do |f|
          f.content = @client.private_key
          f.mode = "0600"
        end
        @client
      end

      def create_node
        chef_api_as_new_client = Chef::REST.new(Chef::Config[:chef_server_url], entity_name, nil, :raw_key => client.private_key)
        @node = Chef::Node.build(entity_name)
        # TODO: wire up user-supplied run_list
        @node.run_list("recipe[tmux]")
        chef_api_as_new_client.post("nodes", @node)
        ui.msg "Created node '#{@node.name}'"
        @node
      end

      ############################################################
      # Config installation.
      #
      # Installs config, creds, etc. to remote box.
      ############################################################


      def install_config(ssh_session)
        stage_files(ssh_session)
        install_staged_files(ssh_session)
      end

      def stage_files(ssh_session)
        log.debug "Making config staging dir #{tempdir}"
        ssh_session.run("mkdir -m 0700 #{@tempdir}")

        files_to_install.each do |file|
          staging_path = temp_path(file.rel_path)
          log.debug "Staging #{file.description} to #{staging_path}"
          ssh_session.scp(file.content, staging_path)
        end
      end

      def install_staged_files(ssh_session)
        log.debug("Creating Chef config directory /etc/chef")
        # TODO: don't hardcode sudo
        ssh_session.pty_run(ssh_session.sudo(<<-SCRIPT))
  bash -c '
    mkdir -p -m 0700 /etc/chef
    chown root:root /etc/chef
    chmod 0755 /etc/chef
  '
  SCRIPT
        files_to_install.each do |file|
          # TODO: support paths outside /etc/chef?
          final_path = File.join("/etc/chef", file.rel_path)
          log.debug("moving staged #{file.description} to #{final_path}")

          # TODO: don't hardcode sudo
          ssh_session.pty_run(ssh_session.sudo(<<-SCRIPT))
  bash -c '
    mv #{temp_path(file.rel_path)} #{final_path}
    chown root:root #{final_path}
    chmod #{file.mode} #{final_path}
  '
  SCRIPT
        end
      end

      def tempdir
        @tempdir ||= "/tmp/chef-bootstrap-#{rand(2 << 128).to_s(16)}"
      end

      def temp_path(rel_path)
        File.join(tempdir, rel_path)
      end
    end

  end
end

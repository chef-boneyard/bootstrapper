require 'chef/rest'
require 'chef/api_client'
require 'securerandom'
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

      option :chef_server_url,
             :type => :string,
             :desc => "URL for your Chef server's API"

      option :chef_username,
             :type => :string,
             :desc => "Username of your account on the Chef server"

      option :chef_api_key,
             :type => :string,
             :desc => "Path to the API key for your user"

      option :node_name,
             :type => :string,
             :desc => "Name of the node to be created"

      option :run_list,
             :type => :string,
             :desc => "Comma separated list of roles/recipes to apply"

      attr_reader :client
      attr_reader :node

      # TODO: extract code to here from base as necessary

      def prepare
        sanity_check

        create_client
        create_node
      end

      # Name for the client/node pair to be created
      # TODO: Should get this from FQDN or -N option, timestamp works for testing purposes.
      def entity_name
        @entity_name ||= Time.new.utc.strftime("%Y-%M-%d-%H-%M-%S")
      end


      ############################################################
      # Chef Client resource creation
      #
      # Sanity checks node and client existence on the server,
      # creates client and node in a way that will make authz happy.
      ############################################################

      def chef_api
        Chef::REST.new(options.chef_server_url, options.chef_username, chef_api_key)
      end

      def chef_api_as_new_client
        Chef::REST.new(options.chef_server_url, entity_name, nil, :raw_key => client.private_key)
      end

      def chef_api_key
        File.expand_path(options.chef_api_key)
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
        # Chef 11 servers only
        response = chef_api.post('clients', :name => entity_name, :admin => false)
        @client = if response.kind_of?(Chef::ApiClient)
          response
        else
          Chef::ApiClient.new.tap do |c|
            c.name(entity_name)
            c.private_key(response["private_key"])
          end
        end

        ui.msg "Created client '#{@client.name}'"

        install_file("client key", "client.pem") do |f|
          f.content = @client.private_key
          f.mode = "0600"
        end
        @client
      end

      def create_node
        @node = build_node
        chef_api_as_new_client.post("nodes", @node)
        ui.msg "Created node '#{@node.name}'"
        @node
      end

      def build_node
        node = Chef::Node.build(entity_name)
        # TODO: wire up user-supplied run_list
        node.run_list(normalized_run_list)
        node
      end

      def normalized_run_list
        run_list_spec = options.run_list
        case run_list_spec
        when nil
          []
        when String
          run_list_spec.split(/\s*,\s*/)
        when Array
          run_list_spec
        end
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
        log.debug "Making config staging dir #{staging_dir}"
        ssh_session.run("mkdir -m 0700 #{@staging_dir}")

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

      def staging_dir
        slug = SecureRandom.hex(16)
        @staging_dir ||= "/tmp/chef-bootstrap-#{slug}"
      end

      def temp_path(rel_path)
        File.join(staging_dir, rel_path)
      end
    end

  end
end

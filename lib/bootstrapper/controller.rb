module Bootstrapper
  class Controller

    attr_accessor :config
    attr_accessor :config_installer
    attr_accessor :chef_installer
    attr_reader :ui

    attr_reader :client

    def initialize(ui, &block)
      @ui = ui
      @config = Config.new
      @config_installer = ConfigInstaller.new
      @chef_installer = ChefInstaller.new
      configure(&block) if block_given?
    end

    def configure
      yield @config
    end

    def chef_api
      Chef::REST.new(Chef::Config[:chef_server_url])
    end

    def log
      Chef::Log
    end

    def run
      sanity_check

      create_client
      create_node

      prepare_installers
      ssh = configure_ssh_session

      ssh.connect do |session|
        log.debug "Installing config files"
        config_installer.install_config(session)
        log.debug "Executing installer..."
        chef_installer.install(session)
      end
    end

    # Name for the client/node pair to be created
    # TODO: Should get this from FQDN or -N option, timestamp works for testing purposes.
    def entity_name
      @entity_name ||= Time.new.strftime("%Y-%M-%d-%H-%M-%S")
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

    def prepare_installers
      chef_installer = ChefInstaller.new
      chef_installer.setup_files(config_installer)
    end

    def configure_ssh_session
      @ssh ||= SSHSession.new(ui, config)
    end
  end
end

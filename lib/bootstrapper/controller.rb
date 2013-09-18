module Bootstrapper
  class Controller

    attr_reader :ui
    attr_reader :definition

    def initialize(ui, definition)
      @ui = ui
      @definition = definition
    end

    def log
      Chef::Log
    end

    def config_generator
      @config_generator ||= definition.config_generator_class.new
    end

    def transport
      @transport ||= definition.transport_class.new(ui)
    end

    def installer
      @installer ||= definition.installer_class.new(ui, transport)
    end

    def run
      # this is where cloudy stuff would go...
      prepare_config
      prepare_installers

      #ssh = configure_ssh_session

      ssh.connect do |session|
        log.debug "Installing config files"
        config_installer.install_config(session)
        log.debug "Executing installer..."
        chef_installer.install(session)
      end
    end



    def prepare_config
      config_generator.prepare
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

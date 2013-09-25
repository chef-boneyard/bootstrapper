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
      @config_generator ||= definition.config_generator_class.new(ui, config_generator_options)
    end

    def config_generator_options
      definition.config_generator_options
    end

    def transport
      @transport ||= definition.transport_class.new(ui, transport_options)
    end

    def transport_options
      definition.transport_options
    end

    def installer
      @installer ||= definition.installer_class.new(ui, installer_options)
    end

    def installer_options
      definition.installer_options
    end

    def run
      # this is where cloudy stuff would go...
      prepare_config
      prepare_installers

      #ssh = configure_ssh_session

      transport.connect do |session|
        ui.msg( "Installing config files" )
        config_generator.install_config(session)
        ui.msg( "Executing installer..." )
        installer.install(session)
      end
    end

    def prepare_config
      config_generator.prepare
    end

    def prepare_installers
      installer.setup_files(config_generator)
    end

    def configure_ssh_session
      @ssh ||= SSHSession.new(ui, config)
    end
  end
end

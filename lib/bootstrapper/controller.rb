module Bootstrapper
  class Controller

    attr_reader :ui
    attr_reader :definition
    attr_reader :cli_options

    def initialize(ui, definition, cli_options)
      @ui = ui
      @definition = definition
      @cli_options = cli_options
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
      apply_cli_options!
      # this is where cloudy stuff would go...
      prepare_config
      prepare_installers

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

    def apply_cli_options!
      [installer_options, transport_options, config_generator_options].each do |component_options|
        component_options.apply_cli_options!(cli_options)
      end
    end
  end
end

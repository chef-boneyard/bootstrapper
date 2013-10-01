module Bootstrapper

  # == Bootstrapper::Controller
  # Orchestrates the various steps in the bootstrap process. Uses the
  # components specified by a Bootstrapper::Definition, applies command line
  # options given in Hash form (as Thor does), and runs them. See #run for a
  # high-level description of the steps in the bootstrapping process.
  class Controller

    # A UI Object for printing messages to the terminal
    attr_reader :ui

    # The Bootstrapper::Definition object that describes the bootstrap
    # components and their base configs.
    attr_reader :definition

    # A Hash of options parsed from the command line. The available options are
    # set by each component of the bootstrap definition, and parsed into Hash
    # form by Thor.
    attr_reader :cli_options

    def initialize(ui, definition, cli_options)
      @ui = ui
      @definition = definition
      @cli_options = cli_options
    end

    # A logger object used to emit debug info.
    def log
      Chef::Log
    end

    # Lazily created instance of the ConfigGenerator implementation specified
    # in the bootstrap definition.
    def config_generator
      @config_generator ||= definition.config_generator_class.new(ui, config_generator_options)
    end

    # A struct-like object that holds the configurable options for the
    # config generator.
    def config_generator_options
      definition.config_generator_options
    end

    # Lazily created instance of the Transport implementation specified in the
    # bootstrap definition.
    def transport
      @transport ||= definition.transport_class.new(ui, transport_options)
    end

    # A struct-like object that holds the configurable options for the
    # transport.
    def transport_options
      definition.transport_options
    end

    # Lazily created instance of the Installer implementation specified in the
    # bootstrap definition.
    def installer
      @installer ||= definition.installer_class.new(ui, installer_options)
    end

    # A struct-like object that holds the configurable options for the
    # installer.
    def installer_options
      definition.installer_options
    end

    # Run the bootstrap, in these steps:
    #
    # 1. Apply options from the CLI to the component specific option objects.
    # 2. Run the ConfigGenerator#prepare method
    # 3. Run the Installer#setup_files method
    # 4. Connect to the remote host via the chosen transport protocol
    # 5. Install config files (ConfigGenerator#install_config)
    # 6. Install Chef (Installer#install)
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

    def apply_cli_options!
      [installer_options, transport_options, config_generator_options].each do |component_options|
        component_options.apply_cli_options!(cli_options)
      end
    end
  end
end

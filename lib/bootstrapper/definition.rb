require 'bootstrapper/dsl_attr'

module Bootstrapper

  # == Bootstrapper::Definition
  # Defines the components and default options used to bootstrap a
  # remote machine with Chef.
  #
  # Definitions are created via a DSL. A definition specifies what
  # transport is used to talk to the remote host (SSH, WinRM), what
  # kind of configuration is generated (chef-client's client.rb and pem
  # file), and how Chef is installed (omnibus, source, etc.). The DSL
  # delegates each of these objects for the purpose of setting default
  # options (so command lines are kept tidy).
  #
  # === Example
  # The general format of a bootstrap definition is:
  #
  # Bootstrapper.define(:bootstrap_name) do |bootstrap|
  #   bootstrap.desc = "Bootstraps Chef over sneakernet by FedExing a USB drive"
  #   bootstrap.transport(:transport_type) do |transport|
  #     transport.option = "value"
  #     # etc.
  #   end
  #   bootstrap.installer(:installer_type) do |installer|
  #     installer.option = "value"
  #     # etc.
  #   end
  #   bootstrap.config_generator(:config_generator_type) do |config_generator|
  #     config_generator.option = "value"
  #     # etc.
  #   end
  # end
  #
  # The exact options available depend on the individual components
  # used.
  #
  class Definition

    class UnknownComponent < StandardError
    end

    def self.definitions_by_name
      @definitions_by_name ||= {}
    end

    def self.by_name(name)
      definitions_by_name[name]
    end

    def self.register(name, definition)
      definitions_by_name[name] = definition
    end

    # Creates a bootstrap definition and stores it in the global list of
    # bootstraps.
    def self.create(name, &block)
      definition = new(name)
      block.call(definition) if block_given?
      register(name, definition)
      name
    end

    # Returns the name of the bootstrap.
    attr_reader :name

    def initialize(name)
      @name = name
      @desc = nil
      @transport = nil
      @installer = nil
      @config_generator = nil
    end

    ############################################################################
    # DSL
    ############################################################################

    # Set or return the short description of this bootstrap. This shows
    # up in help output in the CLI.
    def desc(desc_string=NULL_ARG)
      if desc_string.equal?(NULL_ARG)
        @desc
      else
        @desc = desc_string
      end
    end
    attr_writer :desc

    # Set or return the transport type for this bootstrap. If given a
    # block, it yields an options object that allows you to set defaults
    # for that transport type's options.
    def transport(name=NULL_ARG, &base_config)
      if name.equal?(NULL_ARG)
        @transport
      else
        @transport = name
        # validate it?
        base_config.call(transport_options) if block_given?
        @transport
      end
    end
    attr_writer :transport

    # Set or return the installer type for this bootstrap. If given a
    # block, it yields an options object that allows you to set defaults
    # for that transport type's options.
    def installer(name=NULL_ARG, &base_config)
      if name.equal?(NULL_ARG)
        @installer
      else
        @installer = name
        # validate it?
        base_config.call(installer_options) if block_given?
        @installer
      end
    end
    attr_writer :installer

    # Set or return the config generator type for this bootstrap. If
    # given a block, it yields an options object that allows you to set
    # defaults for that transport type's options.
    def config_generator(name=NULL_ARG, &base_config)
      if name.equal?(NULL_ARG)
        @config_generator
      else
        @config_generator = name
        # validate it?
        base_config.call(config_generator_options) if block_given?
        @config_generator
      end
    end
    attr_writer :config_generator

    ############################################################################
    # Internal public API
    ############################################################################

    def transport_class
      Transport.find(transport) or
        raise UnknownComponent, "Can't load transport type `#{transport}'"
    end

    def installer_class
      Installer.find(installer) or
        raise UnknownComponent, "Can't load installer type `#{installer}'"
    end

    def config_generator_class
      ConfigGenerator.find(config_generator) or
        raise UnknownComponent, "Can't load config generator type `#{config_generator}'"
    end

    def transport_options
      @transport_options ||= transport_class.config_object
    end

    def installer_options
      @installer_options ||= installer_class.config_object
    end

    def config_generator_options
      @config_generator_options ||= config_generator_class.config_object
    end

    def transport_option_list
      transport_class.options
    end

    def installer_option_list
      installer_class.options
    end

    def config_generator_option_list
      config_generator_class.options
    end

    def cli_options
      option_classes = [ transport_option_list,
                         installer_option_list,
                         config_generator_option_list ]
      option_classes.inject([]) do |combined_opts, option_list|
        combined_opts + option_list
      end
    end

  end

end

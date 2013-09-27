require 'bootstrapper/dsl_attr'

module Bootstrapper

  class Definition

    extend DSLAttr

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

    def self.create(name, &block)
      definition = new(name)
      block.call(definition) if block_given?
      register(name, definition)
      name
    end

    attr_reader :name

    def initialize(name)
      @name = name
      @transport = nil
      @installer = nil
      @config_generator = nil
    end

    dsl_attr :desc

    attr_writer :transport
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

    attr_writer :installer
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

    attr_writer :config_generator
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

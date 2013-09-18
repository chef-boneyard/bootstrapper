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
      d = new(name)
      block.call(d) if block_given?
      register(name, d)
      d
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
    dsl_attr :installer
    dsl_attr :config_generator


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
  end

end

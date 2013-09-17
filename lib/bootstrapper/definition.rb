module Bootstrapper

  class Definition

    class UnknownComponent < StandardError
    end

    NULL_ARG = Object.new

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
    attr_accessor :desc
    attr_accessor :transport
    attr_accessor :installer
    attr_accessor :config_generator

    def initialize(name)
      @name = name
      @transport = nil
      @installer = nil
      @config_generator = nil
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
  end

end

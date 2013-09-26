require 'bootstrapper/dsl_attr'
require 'bootstrapper/component_options'

module Bootstrapper
  class Installer

    extend ComponentOptions

    @@installer_classes = {}

    def self.short_name(short_name=NULL_ARG)
      if short_name.equal?(NULL_ARG)
        @short_name
      else
        @@installer_classes[short_name] = self
        @short_name = short_name
      end
    end

    def self.find(short_name)
      @@installer_classes[short_name]
    end

    short_name(:base)

    attr_reader :transport
    attr_reader :options

    def initialize(transport, options)
      @transport = transport
      @options = options
    end

    def setup_files(config_generator)
      raise NotImplementedError
    end

    def install(transport)
      raise NotImplementedError
    end

  end
end

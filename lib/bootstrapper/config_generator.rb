require 'bootstrapper/component_options'

module Bootstrapper

  # Bootstrapper::ConfigGenerator
  # Base class responsible for generating config files and copying them to the
  # remote host.
  class ConfigGenerator

    extend Bootstrapper::ComponentOptions

    @@config_generator_classes = {}

    def self.short_name(short_name)
      @@config_generator_classes[short_name] = self
    end

    def self.find(short_name)
      @@config_generator_classes[short_name]
    end


    class ConfigFile
      attr_reader :description
      attr_reader :rel_path

      attr_accessor :content
      attr_accessor :mode

      def initialize(description, rel_path)
        @description = description
        @rel_path = rel_path
        @content = ""
        @mode = "0600"
      end
    end

    attr_reader :files_to_install
    attr_reader :options
    attr_reader :ui

    def initialize(ui, options)
      @ui = ui
      @options = options
      @files_to_install = []
    end

    def prepare
      raise NotImplementedError
    end

    ############################################################
    # Config installation.
    #
    # Installs config, creds, etc. to remote box.
    ############################################################

    def install_file(description, rel_path)
      file = ConfigFile.new(description, rel_path)
      yield file if block_given?
      @files_to_install << file
    end

    def install_config(transport)
      raise NotImplementedError
    end

    def log
      Chef::Log
    end

  end
end

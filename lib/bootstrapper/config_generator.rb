require 'bootstrapper/component_options'

module Bootstrapper

  # Bootstrapper::ConfigGenerator
  # Base class responsible for generating config files and copying them to the
  # remote host (via the transport class).
  class ConfigGenerator

    extend Bootstrapper::ComponentOptions

    @@config_generator_classes = {}

    # Register this config generator class globally. The `short_name` given
    # here is used in the bootstrap definition DSL to lookup the desired config
    # generator type.
    #
    # === Example:
    # Given a config generator class like this:
    #
    #   class ChefClientConfig < ConfigGenerator
    #     short_name :chef_client
    #     # other code
    #   end
    #
    # A user can set this config generator in the bootstrap DSL like:
    #
    # Bootstrapper.define(:my_bootsrap) do |b|
    #   b.config_generator(:chef_client) do |c|
    #     # set config_generator options
    #   end
    #   # etc.
    #
    def self.short_name(short_name)
      @@config_generator_classes[short_name] = self
    end

    def self.find(short_name)
      @@config_generator_classes[short_name]
    end


    # Describes a file to be transferred to the remote host.
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

    # An Array of ConfigFile objects to be transferred to the remote box.
    attr_reader :files_to_install

    # The ComponentOptionCollection containing the values of the user-settable
    # options.
    attr_reader :options

    # UI object for displaying messages to the terminal.
    attr_reader :ui

    def initialize(ui, options)
      @ui = ui
      @options = options
      @files_to_install = []
    end

    # Runs any necessary preflight steps required for config generation. For
    # example, the ChefClient config generator creates a client and node
    # identity on the server in this step.
    #
    # Must be defined by implementation classes.
    def prepare
      raise NotImplementedError
    end

    ############################################################
    # Config installation.
    #
    # Installs config, creds, etc. to remote box.
    ############################################################

    # Adds a ConfigFile to the list of files to be transferred to the remote
    # host (but does not transfer it immediately).
    def install_file(description, rel_path)
      file = ConfigFile.new(description, rel_path)
      yield file if block_given?
      @files_to_install << file
    end

    # Installs the necessary configuration on the remote host via the given
    # `transport`.
    #
    # Must be defined by implementation classes
    def install_config(transport)
      raise NotImplementedError
    end

    # A logger object that can be used to emit debugging info.
    def log
      Chef::Log
    end

  end
end

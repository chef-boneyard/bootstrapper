require 'bootstrapper/dsl_attr'
require 'bootstrapper/component_options'

module Bootstrapper

  # == Bootstrapper::Installer
  # Base class responsible for installing Chef on a remote host.
  class Installer

    extend ComponentOptions

    @@installer_classes = {}

    # Sets or returns the short name of the installer class. This is used in
    # the bootstrap definition DSL when selecting an installer type.
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

    # The transport object for this bootstrap.
    attr_reader :transport

    # The implementation specific transport options.
    attr_reader :options

    def initialize(transport, options)
      @transport = transport
      @options = options
    end

    # Adds any files (such as an install script) required by the installer to
    # the list of files the config_generator will transfer to the remote host.
    # The actual transfer happens in a later step.
    #
    # Must be implemented by subclasses.
    def setup_files(config_generator)
      raise NotImplementedError
    end

    # Runs the install process via the `transport` object.
    #
    # Must be implemented by subclasses.
    def install(transport)
      raise NotImplementedError
    end

  end
end

require 'bootstrapper/component_options'
require 'chef/log'

module Bootstrapper

  # == Bootstrapper::Transport
  # Base class responsible for setting up a network connection to the remote
  # host. A Transport class only needs to set up the connection (when the
  # #connect method is called) and yield a session object, which probably will
  # be a subclass of TransportSession. The TransportSession object is
  # responsible for providing convenient methods for running commands and
  # copying files.
  class Transport

    extend Bootstrapper::ComponentOptions

    @@transport_classes = {}

    # Sets or returns the short name for this class. The short name is used in
    # the DSL to select a transport type.
    def self.short_name(short_name=NULL_ARG)
      unless short_name.equal?(NULL_ARG)
        @short_name = short_name
        @@transport_classes[short_name] = self
      end
      @short_name
    end

    # Lookup a tranport type by short name
    def self.find(short_name)
      @@transport_classes[short_name]
    end

    # Returns the object that stores the (implementation-specific)
    # user-settable options.
    attr_reader :options

    # A UI object for printing output to the terminal.
    attr_reader :ui

    def log
      Chef::Log
    end

    def initialize(ui, options)
      @ui = ui
      @options = options
    end

    # Connects to the remote host and yields an object encapsulating the
    # session. The yielded object is expected to respond to the methods defined
    # by TransportSession.
    def connect
      raise NotImplementedError
    end

  end

end

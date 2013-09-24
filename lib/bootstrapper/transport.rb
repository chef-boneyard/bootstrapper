require 'bootstrapper/component_options'
require 'chef/log'

module Bootstrapper
  class Transport

    extend Bootstrapper::ComponentOptions

    @@transport_classes = {}

    def self.short_name(short_name)
      @@transport_classes[short_name] = self
    end

    def self.find(short_name)
      @@transport_classes[short_name]
    end

    attr_reader :options
    attr_reader :ui

    def log
      Chef::Log
    end

    def initialize(ui, options)
      @ui = ui
      @options = options
    end

  end

end

module Bootstrapper
  class Installer

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

    def initialize(transport)
      @transport = transport
    end

    def install
      raise NotImplementedError
    end

  end
end

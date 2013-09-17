module Bootstrapper
  class Installer

    @@installer_classes = {}

    def self.short_name(short_name)
      @@installer_classes[short_name] = short_name
    end

    def self.find(short_name)
      @@installer_classes[short_name]
    end


    def initialize(transport)
      @transport = transport
    end

    def install
      raise NotImplementedError
    end

  end
end

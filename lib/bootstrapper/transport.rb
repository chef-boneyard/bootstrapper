
module Bootstrapper
  class Transport

    @@transport_classes = {}

    def self.short_name(short_name)
      @@transport_classes[short_name] = self
    end

    def self.find(short_name)
      @@transport_classes[short_name]
    end

    attr_reader :session
    attr_reader :config
    attr_reader :ui

    def initialize(ui, session, config)
      @ui = ui
      @session = session
      @config = config
    end

    def log
      Chef::Log
    end

    def scp(io_or_string, remote_path)
      raise NotImplementedError
    end

    def pty_run(command)
      raise NotImplementedError
    end

  end

end

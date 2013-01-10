module Bootstrapper

  # == Bootstrapper::SSHSession
  # A wrapper around Net::SSH connection.
  class SSHSession

    attr_reader :config
    attr_reader :ui

    def log
      Chef::Log
    end

    def initialize(ui, config=nil, &config_block)
      @ui = ui
      @config = config || Config.new
      configure(&config_block) if block_given?
    end

    def configure
      yield config
    end

    def connect
      attempts ||= 0
      log.debug "Connecting to cloud_server: #{config.printable_ssh_config}"
      Net::SSH.start(*ssh_options) do |ssh|
        yield SSHSessionController.new(ui, ssh, config)
      end
    rescue Net::SSH::AuthenticationFailed => e
      ui.msg("Authentication failed for #{e}")
      if STDOUT.tty? and attempts < 3
        password = ui.ask("login password for #{e}@#{config.host}:") { |q| q.echo = false }
        config.password = password
        attempts += 1
        retry
      else
        raise
      end
    end

    def ssh_options
      config.to_net_ssh_config
    end
  end
end

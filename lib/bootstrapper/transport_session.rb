module Bootstrapper

  # == Bootstrapper::TransportSession
  # Subclasses of Bootstrapper::Transport handle the details
  # of setting up a connection to the remote machine. Subclasses of
  # Bootstrapper::TransportSession are responsible for providing a
  # convenient interface to the underlying transport session and handling
  # the details of running commands, copying files, etc.
  #
  # For example, Transports::SSH deals with connecting to the remote box,
  # dealing with proxies if necessary, and authenticating the user via
  # their key or password. Once the SSH session is established, it yields a
  # SSHSession object which provides methods for running commands, copying
  # files, etc.
  class TransportSession
    attr_reader :session
    attr_reader :options
    attr_reader :ui

    def initialize(ui, session, options)
      @ui = ui
      @session = session
      @options = options
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

    def run(command)
      raise NotImplementedError
    end

    def sudo(command)
      raise NotImplementedError
    end
  end
end

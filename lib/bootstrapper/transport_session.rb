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

    # An object representing the connection details of the underlying transport
    # protocol.
    attr_reader :session

    # The user-configured options for this transport type.
    attr_reader :options

    # A UI object for printing feedback to the terminal.
    attr_reader :ui

    def initialize(ui, session, options)
      @ui = ui
      @session = session
      @options = options
    end

    def log
      Chef::Log
    end

    # Copy a raw string or IO (or IO-like) object to the remote host at the
    # given remote_path.
    #
    # Must be defined by subclasses.
    def scp(io_or_string, remote_path)
      raise NotImplementedError
    end

    # Run a command on the remote host with a PTY (if applicable). This is used
    # so programs that prompt for input (like sudo) can be used. The
    # implementation is responsible for displaying any prompts back to the user
    # and relaying user input.
    #
    # If quiet mode is specified, command output is suppressed except when the
    # remote host prompts for input.
    #
    # Must be defined by subclasses.
    def pty_run(command, quiet=false)
      raise NotImplementedError
    end

    # Run a command on the remote host.
    #
    # Must be defined by subclasses.
    def run(command)
      raise NotImplementedError
    end

    # Convert a command in String form to a "sudo'd" form and return it as a
    # string. In a UNIX environment, this is similar to prepending the command
    # with "sudo", however it may be more complicated for implementation
    # reasons. This could be a no-op if already running as an administrator.
    #
    # Must be defined by subclasses.
    def sudo(command)
      raise NotImplementedError
    end
  end
end

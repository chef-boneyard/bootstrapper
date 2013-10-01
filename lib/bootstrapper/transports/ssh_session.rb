require 'bootstrapper/transport_session'

module Bootstrapper
  module Transports

    # == SSHSession
    # Wraps an SSH session with convenience methods for running commands (with
    # sudo) and scp-ing files.
    class SSHSession < TransportSession
      class ExecuteFailure < ArgumentError
      end

      def scp(io_or_string, path)
        io = if io_or_string.respond_to?(:read_nonblock)
               io_or_string
             else
               StringIO.new(io_or_string)
             end
        session.scp.upload!(io, path)
      end

      def run(cmd, desc=nil)
        log.info(desc) if desc
        log.debug "Executing remote command: #{cmd}"
        result = session.exec!(cmd)
        log.debug "result: #{cmd}"
        result
      end

      def pty_run(command, quiet=false)
        exit_status = nil
        session.open_channel do |channel|
          channel.request_pty
          channel.exec(command) do |ch, success|
            raise ExecuteFailure, "Cannot execute (on #{remote_host}) command `#{command}'" unless success
            ch.on_data do |ichannel, data|
              # TODO: stream this the right way.
              # TODO: detect incorrect sudo password and deal with it.
              if data =~ /^SUDO PASSWORD FOR/
                ichannel.send_data("#{get_password}\n")
              else
                display(data) unless quiet
              end
            end
            ch.on_request "exit-status" do |ichannel, data|
              exit_status = data.read_long
            end
          end
          channel.wait
        end

        session.loop # block until the command is done executing
        exit_status
      end

      def display(data)
        if multi_host_output?
          data.split(/\n/).each do |line|
            str = "#{ui.color(options.host, :cyan)} #{line}"
            ui.msg(str)
          end
        else
          ui.stdout.print(data)
        end
      end

      def sudo(cmd)
        "sudo -p 'SUDO PASSWORD FOR #{remote_host}:' #{cmd}"
      end

      def get_password
        @password ||= ui.ask("sudo password for #{options.user}@#{remote_host}:") { |q| q.echo = false }
      end

      def remote_host
        options.host
      end

      def multi_host_output?
        options.multi_host
      end
    end
  end
end

require 'net/ssh'
require 'net/scp'

require 'bootstrapper/transport'

module Bootstrapper
  module Transports
    # == Bootstrapper::SSH
    # Provides a Transport implementation for SSH
    class SSH < Transport

      short_name(:ssh)

      option :password,
        :type => :string,
        :desc => "The ssh password"

      option :port,
        :type => :numeric,
        :desc => "The ssh port"

      option :gateway,
        :type => :string,
        :desc => "The ssh gateway"

      option :identity_file,
        :type => :string,
        :desc => "The SSH identity file used for authentication"

      option :host_key_verify,
        :type => :boolean,
        :default => true

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

      def pty_run(command)
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
                display(data)
              end
            end
            ch.on_request "exit-status" do |ichannel, data|
              exit_status = data.read_long
            end
          end
        end
        exit_status
      end

      def display(data)
        data.split(/\n/).each do |line|
          str = "#{ui.color(config.host, :cyan)} #{line}"
          ui.msg(str)
        end
      end

      def sudo(cmd)
        "sudo -p 'SUDO PASSWORD FOR #{remote_host}:' #{cmd}"
      end

      def get_password
        @password ||= ui.ask("sudo password for #{config.user}@#{remote_host}") { |q| q.echo = false }
      end

      def remote_host
        config.host
      end

    end
  end
end

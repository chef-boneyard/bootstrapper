require 'net/ssh'
require 'net/scp'

require 'bootstrapper/transport'
require 'bootstrapper/transports/ssh_session'

# TODO: Chef::Knife::Ui relies on Chef::Config being loaded;
# either replace Ui with a local version or move this require up.
require 'chef/config'

module Bootstrapper
  module Transports


    # == Bootstrapper::SSH
    # Provides a Transport implementation for SSH
    class SSH < Transport

      short_name(:ssh)

      option :host,
        :type => :string,
        :desc => "The host to bootstrap"

      option :user,
        :type => :string,
        :desc => "User to login as"

      # TODO: infer this from root/not-root username?
      option :sudo,
        :type => :boolean,
        :desc => "whether to use sudo"

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

      option :multi_host,
        :type => :boolean,
        :desc => "Whether to optimize output for multiple hosts"

      def connect
        attempts ||= 0
        log.debug "Connecting to remote over SSH: #{printable_ssh_config}"
        Net::SSH.start(*net_ssh_config) do |ssh|
          yield SSHSession.new(ui, ssh, options)
        end
      rescue Net::SSH::AuthenticationFailed => e
        ui.msg("Authentication failed for #{e}")
        if STDOUT.tty? and attempts < 3
          password = ui.ask("login password for #{e}@#{options.host}:") { |q| q.echo = false }
          options.password = password
          attempts += 1
          retry
        else
          raise
        end
      end

      def net_ssh_config
        ssh_opts = {}

        ssh_opts[:port] = options.port

        ssh_opts[:password] = options.password

        if options.identity_file
          ssh_opts[:keys] = [options.identity_file]
          ssh_opts[:keys_only] = true
        end

        # Should be computed in config
        if options.host_key_verify == false
          ssh_opts[:paranoid] = false
          ssh_opts[:user_known_hosts_file] = "/dev/null"
        elsif options.host_key_verify
          ssh_opts[:paranoid] = true
          ssh_opts[:user_known_hosts_file] = nil
        end

        ssh_opts[:logger] = log if log.debug?

        [ options.host, options.user, ssh_opts ]
      end

      def printable_ssh_config
        if net_ssh_config[2].key?(:password) && !net_ssh_config[2][:password].nil?
          net_ssh_config[2][:password] = "***Password Concealed**"
        end
        net_ssh_config
      end

    end
  end
end

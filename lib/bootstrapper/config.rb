require 'uri'

module Bootstrapper

  # == Bootstrapper::Config
  # Local config data for an individual bootstrap invocation. It is intentional
  # that a globally accessible config object is not used (e.g., Chef::Config).
  # Firstly, it allows multiple instances to exist simultaneously, so it is
  # possible to run multiple bootstraps in parallel with threads. Secondly, by
  # allowing configuration of individual instances of the components, it is
  # easier to use them as libraries.
  #
  # Adapter methods are provided to merge configuration data from Chef::Config
  # and knife's +config+ attribute.
  class Config

    attr_accessor :host
    attr_accessor :port

    attr_accessor :user
    attr_accessor :password
    attr_accessor :keys

    attr_accessor :gateway

    attr_accessor :paranoid
    attr_accessor :user_known_hosts_file

    attr_accessor :logger

    def hostspec=(uri)
      uri = if uri =~ %r{^ssh://}
              uri
            else
              "ssh://#{uri}"
            end
      u = URI.parse(uri)
      @user = u.user unless u.user.nil?
      @host = u.host
    end

    def hostspec
      u = ""
      u << "#{user}@" unless user.nil?
      u << host
    end

    def apply_knife_config(config)
      # TODO: ssh_gateway support
      # config[:ssh_gateway] ||= Chef::Config[:knife][:ssh_gateway]
      # if config[:ssh_gateway]
      #   gw_host, gw_user = config[:ssh_gateway].split('@').reverse
      #   gw_host, gw_port = gw_host.split(':')
      #   gw_opts = gw_port ? { :port => gw_port } : {}

      #   session.via(gw_host, gw_user || config[:ssh_user], gw_opts)
      # end

      self.user = config[:ssh_user] if config[:ssh_user]
      self.password = config[:ssh_password] if config[:ssh_password]
      self.keys = File.expand_path(config[:identity_file]) if config[:identity_file]

      self.port = config[:ssh_port] if config[:ssh_port]

      # TODO: turn this back on.
      #self.logger = Chef::Log.logger if Chef::Log.level == :debug

      # Don't reconfigure if nil
      if config[:host_key_verify] == false
        self.paranoid = false
        self.user_known_hosts_file = "/dev/null"
      elsif config[:host_key_verify]
        self.paranoid = true
        self.user_known_hosts_file = nil
      end
    end

    def apply_chef_config(chef_config)
      apply_knife_config(chef_config[:knife])
    end

    def to_net_ssh_config
      ssh_opts = {}

      ssh_opts[:port] = port

      ssh_opts[:password] = password

      ssh_opts[:keys] = keys
      ssh_opts[:keys_only] = true if keys

      ssh_opts[:paranoid] = paranoid
      ssh_opts[:user_known_hosts_file] = user_known_hosts_file

      ssh_opts[:logger] = logger

      [ host, user, ssh_opts ]
    end

    def printable_ssh_config
      net_ssh_config = self.to_net_ssh_config
      if net_ssh_config[2].key?(:password) && !net_ssh_config[2][:password].nil?
        net_ssh_config[:password] = "***Password Concealed**"
      end
      net_ssh_config
    end
  end
end

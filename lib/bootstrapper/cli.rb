require 'thor'
require 'chef/knife/core/ui'

module Bootstrapper

  class CLI < Thor

    option :ssh_password,
      :short => "-P PASSWORD",
      :long => "--ssh-password PASSWORD",
      :description => "The ssh password"

    option :ssh_port,
      :short => "-p PORT",
      :long => "--ssh-port PORT",
      :description => "The ssh port",
      :proc => Proc.new { |key| Chef::Config[:knife][:ssh_port] = key }

    option :ssh_gateway,
      :short => "-G GATEWAY",
      :long => "--ssh-gateway GATEWAY",
      :description => "The ssh gateway",
      :proc => Proc.new { |key| Chef::Config[:knife][:ssh_gateway] = key }

    option :identity_file,
      :short => "-i IDENTITY_FILE",
      :long => "--identity-file IDENTITY_FILE",
      :description => "The SSH identity file used for authentication"

    option :host_key_verify,
      :long => "--[no-]host-key-verify",
      :description => "Verify host key, enabled by default.",
      :boolean => true,
      :default => true

    desc "hax", "run the default bootstrap with dev hax"
    def hax
      require 'bootstrapper/bootstraps/default'
      ui = Chef::Knife::UI.new($stdout, $stderr, $stdin, {})

      definition = Definition.by_name(:standard) or raise "failed to load default definition"

      bootstrapper = Bootstrapper::Controller.new(ui, definition)
      bootstrapper.run
    end

  end
end

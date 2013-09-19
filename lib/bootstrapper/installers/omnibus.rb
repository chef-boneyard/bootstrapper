require 'bootstrapper/installer'

module Bootstrapper
  module Installers

    # == Bootstrapper::ChefInstaller
    # Installs chef on the remote machine.
    class Omnibus < Installer

      option :bootstrap_version

      short_name(:omnibus)

      def setup_files(config_generator)
        config_generator.install_file("bootstrap script", "bootstrap.sh") do |f|
          f.content = install_script
          f.mode = "0755"
        end
      end

      def install_script
        <<-SCRIPT
set -x
bash <(wget https://www.opscode.com/chef/install.sh -O -) -v #{install_version}
SCRIPT
      end

      def install_version
        options.bootstrap_version || "latest"
      end

      def install(transport)
        transport.pty_run(transport.sudo("bash -x /etc/chef/bootstrap.sh"))
      end
    end
  end
end

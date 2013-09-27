require 'bootstrapper/installer'

module Bootstrapper
  module Installers
    class TestInstaller < Installer

      short_name :test_installer

      option :installer_opt,
             :type => :string,
             :desc => "Optional setting for test installer"

      attr_reader :install_ran

      def install(transport)
        @install_ran = true
      end

      def setup_files(config_generator)
      end

    end
  end
end

require 'bootstrapper/installer'

module Bootstrapper
  module Installers
    class TestInstaller < Installer

      short_name :test_installer

      option :installer_opt,
             :type => :string,
             :desc => "Optional setting for test installer"

      def install(transport)
      end

      def setup_files(config_generator)
      end

    end
  end
end

require 'bootstrapper/config_generator'

module Bootstrapper
  module ConfigGenerators
    class TestConfigGenerator < ConfigGenerator

      short_name :test_config_generator

      option :config_generator_opt,
             :type => :string,
             :desc => "A configurable opt for a config generator"

      def prepare
      end

      def install_config(transport)
      end

    end
  end
end

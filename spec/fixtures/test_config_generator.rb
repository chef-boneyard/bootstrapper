require 'bootstrapper/config_generator'

module Bootstrapper
  module ConfigGenerators
    class TestConfigGenerator < ConfigGenerator

      short_name :test_config_generator

      option :config_generator_opt,
             :type => :string,
             :desc => "A configurable opt for a config generator"

      attr_reader :install_config_ran

      def prepare
      end

      def install_config(transport)
        @install_config_ran = true
      end

      def run_chef(transport, installer)
      end

    end
  end
end

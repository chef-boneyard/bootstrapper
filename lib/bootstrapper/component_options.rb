require 'bootstrapper/dsl_attr'
module Bootstrapper

  # == Bootstrapper::ComponentOptions
  # Class extension allowing you to define CLI options relevant to a particular
  # component in the class definition of that component. Also generates a
  # struct class based on the available options so they can be configured in
  # the definition DSL.
  #
  # Options are fed to Thor to generate the CLI, however the shortcut syntaxes
  # supported by thor (e.g., `option :opt_name => :required`) aren't supported.
  module ComponentOptions

    # == Bootstrapper::ComponentOptions::ComponentOptionCollection
    # Base class for a component's (transport, installer, config_generator)
    # options.
    class ComponentOptionCollection

      def self.configurables
        @configurables ||= []
      end

      def self.configurable(attr_name)
        attr_writer attr_name
        ivar = "@#{attr_name}"
        # default value of block arg not ruby 18 friendly
        define_method(attr_name) do |value=NULL_ARG|
          if value.equal?(NULL_ARG)
            instance_variable_get(ivar)
          else
            instance_variable_set(ivar, value)
          end
        end
        configurables << attr_name
        attr_name
      end

      def apply_cli_options!(cli_options)
        self.class.configurables.each do |configurable_opt|
          if new_value = cli_options[configurable_opt]
            apply_cli_option!(configurable_opt, new_value)
          end
        end
      end

      def apply_cli_option!(option_name, value)
        send(option_name, value)
      end

    end

    def options
      @options ||= []
    end

    def option(name, meta_options={})
      config_object_class.configurable(name)
      options << [name, meta_options]
      name
    end

    def config_object_class
      @config_object_class ||= begin
        config_class = Class.new(ComponentOptionCollection)
        self.const_set(:ConfigOptions, config_class)
        config_class
      end
    end

    def config_object
      config_object_class.new
    end
  end
end

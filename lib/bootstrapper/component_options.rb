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

    def options
      @options ||= []
    end

    def option(name, meta_options={})
      config_object_class.dsl_attr(name)
      options << [name, meta_options]
      name
    end

    def config_object_class
      @config_object_class ||= begin
        config_class = Class.new
        config_class.extend(DSLAttr)
        self.const_set(:ConfigOptions, config_class)
        config_class
      end
    end

    def config_object
      config_object_class.new
    end
  end
end

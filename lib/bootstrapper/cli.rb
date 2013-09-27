require 'thor'
require 'chef/knife/core/ui'

module Bootstrapper

  class CLI < Thor

    class << self
      # SomeClass.start is the normal entry point for a Thor-based
      # program, but CLI wraps this method with special logic so it can
      # look at the ARGV first, therefore it's an internal API.
      private :start
    end

    def self.run(argv, config={})
      load_definition_if_given(argv)
      load_all_definitions

      # HACK :(
      # Thor doesn't provide an easy way to get the instance back when
      # running start (or to create it without running the command), so
      # we have to copy-pasta some of Thor's code to hack this in.
      #
      instance = nil
      config[:shell] ||= Thor::Base.shell.new
      dispatch(nil, argv.dup, nil, config) {|i| instance = i }
      instance
    rescue Thor::Error => e
      ENV["THOR_DEBUG"] == "1" ? (raise e) : config[:shell].error(e.message)
      exit(1) if exit_on_failure?
    rescue Errno::EPIPE
      # This happens if a thor command is piped to something like `head`,
      # which closes the pipe when it's done reading. This will also
      # mean that if the pipe is closed, further unnecessary
      # computation will not occur.
      exit(0)
    end

    def self.load_all_definitions
      Definition.definitions_by_name.each do |name, definition|
        define_bootstrap(definition)
      end
    end

    def self.load_definition_if_given(argv)
      while file_to_load = extract_file_load_option(argv)
        load(file_to_load)
      end
    end

    def self.extract_file_load_option(argv)
      if file_flag_index = (argv.index("-f") || argv.index("--file"))
        file_to_load_index = file_flag_index + 1
        file_to_load = argv[file_to_load_index]
        # TODO: Validate input
        file_name = validate_definition_file(file_to_load)
        argv.delete_at(file_to_load_index)
        argv.delete_at(file_flag_index)
        file_name
      else
        false
      end
    end

    def self.validate_definition_file(file_to_load)
      if file_to_load.nil? || file_to_load =~/^\-/
        shell.say("Error: Option `-f bootstrap_file` requires an argument.")
        help(shell)
      end

      full_path_to_load = File.expand_path(file_to_load)

      if !File.readable?(full_path_to_load)
        shell.say("Error: Bootstrap file `#{file_to_load}` doesn't exist or cannot be read.")
        help(shell)
      end

      full_path_to_load
    end

    def self.execute_definition(file, argv)
      argv.unshift(definition_name.to_s)
      start(argv)
    end

    def self.help(shell, subcommand=false)
      shell.say(<<-USAGE)
USAGE: bootstrap [-f bootstrap_file] bootstrap_name [boostrap_specific_options]

USAGE
      super

      shell.say(<<-HINT)

For help with custom bootstrap commands:

  bootstrap -f BOOTSTRAP_FILE -h
  bootstrap -f BOOTSTRAP_FILE help BOOTSTRAP NAME
HINT
      exit 1
    end

    def self.shell
      @shell ||= Thor::Base.shell.new
    end

    def self.define_bootstrap(definition)
      desc(definition.name.to_s, definition.desc)
      definition.cli_options.each do |name, opt_opts|
        option(name, opt_opts)
      end

      define_method(definition.name.to_sym) do
        run_bootstrap(definition)
      end
    end

    class_option :file,
                 :desc => "Load a bootstrap definition file",
                 :type => :string,
                 :aliases => :f

    class_option :help,
                 :desc => "Help for this command",
                 :type => :boolean,
                 :aliases => :h

    attr_reader :controller

    no_commands do

      def run_bootstrap(definition)
        return help(definition.name) if options[:help]

        ui = Chef::Knife::UI.new($stdout, $stderr, $stdin, {})

        @controller = Bootstrapper::Controller.new(ui, definition)
        @controller.run
        @controller
      end

    end

  end
end

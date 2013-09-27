require 'spec_helper'
require 'bootstrapper/cli'

require 'fixtures/test_transport'
require 'fixtures/test_config_generator'
require 'fixtures/test_installer'

describe Bootstrapper::CLI do

  let(:spec_root) { File.expand_path("../..", __FILE__) }

  describe "parsing arguments" do

    let(:shell) { double("Thor Shell object") }
    let(:cli) do
      shell.stub(:say)
      shell.stub(:print_table).with(an_instance_of(Array), an_instance_of(Hash))
      Bootstrapper::CLI.stub(:shell).and_return(shell)
      Bootstrapper::CLI
    end

    describe "when given bad definition file options" do
      it "handles a missing value to -f" do
        shell.should_receive(:say).with("Error: Option `-f bootstrap_file` requires an argument.")
        expect {cli.run(%w{ -f })}.to raise_error(SystemExit)
      end

      it "handles a missing value to -f followed by another option" do
        shell.should_receive(:say).with("Error: Option `-f bootstrap_file` requires an argument.")
        expect { cli.run(%w{ -f -h }) }.to raise_error(SystemExit)
      end

      it "handles a non-existent definition file" do
        shell.should_receive(:say).with("Error: Bootstrap file `fixtures/no-file-here.rb` doesn't exist or cannot be read.")
        Dir.chdir(spec_root) do
          expect { cli.run(%w{ -f fixtures/no-file-here.rb} ) }.to raise_error(SystemExit)
        end
      end
    end
    context "when given a definition file" do
      let(:argv) { %w[-f fixtures/example-definition.rb example --installer-opt foo --transport-opt bar --config-generator-opt baz] }

      it "loads the file and executes the bootstrap" do
        cli_instance = Dir.chdir(spec_root) do
          Bootstrapper::CLI.run(argv)
        end
        expect(cli_instance.public_methods.map(&:to_s)).to include("example")
        controller = cli_instance.controller
        expect(controller.installer.install_ran).to be_true
        expect(controller.config_generator.install_config_ran).to be_true
        expect(controller.transport.connect_ran).to be_true
      end
    end

    context "when given a command to load a known bootstrap definition" do
      let(:argv) { %[my-cloud-bootstrap --opt-a baz --opt-b qux] }

      it "runs the bootstrap defined by the subcommand" do
        pending
      end
    end
  end

end

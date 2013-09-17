require 'spec_helper'
require 'bootstrapper/cli'

describe Bootstrapper::CLI do

  describe "parsing arguments" do
    context "when given a definition file" do
      let(:argv) { %w[fixtures/example-definition.rb --opt-a foo --opt-b bar] }

      it "loads the file and executes the bootstrap" do
        pending
      end
    end

    context "when given a command to load a known bootstrap definition" do
      let(:argv) { %[my-cloud-bootstrap --opt-a baz --opt-b qux] }

      it "runs the bootstrap defined by the subcommand" do
        pending
      end
    end
  end

  it "generates a cli subcommand from a definition file" do
    pending
  end

end

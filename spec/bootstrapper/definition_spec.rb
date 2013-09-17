require 'spec_helper'
require 'bootstrapper/definition'

describe Bootstrapper::Definition do

  let(:definition) { Bootstrapper::Definition.new("rspec-example") }

  it "has a name" do
    expect(definition.name).to eq("rspec-example")
  end

  it "specifies a description" do
    definition.desc = "An example bootstrap definition"
    expect(definition.desc).to eq("An example bootstrap definition")
  end

  it "specifies a transport type" do
    definition.transport = :ssh
    expect(definition.transport).to eq(:ssh)
  end

  it "specifies an installer type" do
    definition.installer = :omnibus
    expect(definition.installer).to eq(:omnibus)
  end

  it "specifies a config_generator type" do
    definition.config_generator = :chef_client
  end

  describe "when loading a definition file" do

    it "returns the name of the definition it loaded" do
      pending
    end

    it "registers the definition name globally" do
      pending
    end
  end

end

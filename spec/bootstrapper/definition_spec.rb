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
    definition.transport(:ssh)
    expect(definition.transport).to eq(:ssh)
  end

  it "specifies an installer type" do
    definition.installer(:omnibus)
    expect(definition.installer).to eq(:omnibus)
  end

  it "specifies a config_generator type" do
    definition.config_generator(:chef_client)
    expect(definition.config_generator).to eq(:chef_client)
  end

  it "finds a transport class by short name" do
    definition.transport(:ssh)
    expect(definition.transport_class).to eq(Bootstrapper::Transports::SSH)
  end

  it "finds an installer class by short name" do
    definition.installer(:omnibus)
    expect(definition.installer_class).to eq(Bootstrapper::Installers::Omnibus)
  end

  it "finds a config generator class by short name" do
    definition.config_generator(:chef_client)
    expect(definition.config_generator_class).to eq(Bootstrapper::ConfigGenerators::ChefClient)
  end

  it "yields config options for transport" do
    definition.transport(:ssh) do |ssh|
      ssh.port = 22
      ssh.identity_file = "/tmp/foo"
    end
    transport_opts = definition.transport_options
    expect(transport_opts.port).to eq(22)
    expect(transport_opts.identity_file).to eq("/tmp/foo")
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

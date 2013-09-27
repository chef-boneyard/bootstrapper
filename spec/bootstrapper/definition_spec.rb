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

  it "yields config options for config generation" do
    definition.config_generator(:chef_client) do |chef|
      chef.chef_server_url = "https://api.opscode.com/organizations/example"
      chef.chef_username = "charlie"
      chef.chef_api_key = "~/.chef/charlie.pem"
    end
    config_generator_opts = definition.config_generator_options
    expect(config_generator_opts.chef_server_url).to eq("https://api.opscode.com/organizations/example")
    expect(config_generator_opts.chef_username).to eq("charlie")
    expect(config_generator_opts.chef_api_key).to eq("~/.chef/charlie.pem")
  end

  it "yields config options for the installer" do
    definition.installer(:omnibus) do |omnibus|
      omnibus.bootstrap_version = "11.6.0"
    end
    installer_opts = definition.installer_options
    expect(installer_opts.bootstrap_version).to eq("11.6.0")
  end

  describe "when loading a definition file" do
    before do
      definition = nil
      Bootstrapper::Definition.create(:register_test) do |defn|
        definition = defn
        # definition code here
      end
      @definition = definition
    end

    it "registers the definition name globally" do
      expect(Bootstrapper::Definition.definitions_by_name[:register_test]).to eq(@definition)
    end
  end

end

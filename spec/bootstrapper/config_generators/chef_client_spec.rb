require 'spec_helper'
require 'shared/config_generator'
require 'chef/knife/core/ui'
require 'bootstrapper/config_generators/chef_client'

describe Bootstrapper::ConfigGenerators::ChefClient do

  it_should_behave_like "A Config Generator"

  let(:transport) { double("Transport Object") }
  let(:options) { Bootstrapper::ConfigGenerators::ChefClient.config_object }
  let(:ui) { Chef::Knife::UI.new(StringIO.new, StringIO.new, StringIO.new, {}) }
  let(:config_generator) { Bootstrapper::ConfigGenerators::ChefClient.new(ui, options) }


  describe "configurable options" do

    let(:options_collection) { Bootstrapper::ConfigGenerators::ChefClient.options }

    it "configures the chef server URL" do
      opts = {:type=>:string,
              :desc=>"URL for your Chef server's API"}
      expect(options_collection).to include([:chef_server_url, opts])
    end

    it "configures the chef server username" do
      opts = {:type=>:string,
              :desc=>"Username of your account on the Chef server"}
      expect(options_collection).to include([:chef_username, opts])
    end

    it "configures the chef API key" do
      opts = {:type => :string,
              :desc => "Path to the API key for your user"}
      expect(options_collection).to include([:chef_api_key, opts])
    end

    it "configures the desired node/client name" do
      opts = {:type=>:string,
              :desc=>"Name of the node to be created"}
      expect(options_collection).to include([:node_name, opts])
    end

    it "configures the desired run_list" do
      opts = {:type => :string,
              :desc => "Comma separated list of roles/recipes to apply"}
      expect(options_collection).to include([:run_list, opts])
    end

  end

  context "when no node name is specified" do

    # NOTE: current bootstrap behavior uses node FQDN. This could be inferred
    # from the bootrap arguments or "baby ohai" shell script run over ssh on
    # the target. Or we could just forget about it.
    it "generates a node name based on timestamp" do
      now = Time.at(1379712028)
      Time.stub(:new).and_return(now)
      expect(config_generator.entity_name).to eq("2013-20-20-21-20-28")
    end

  end

  describe "generating resources on the chef server" do
    let(:chef_server_url) { "http://localhost:22222" }
    let(:chef_username) { "deuce" }
    let(:chef_api_key_short) { "~/.chef/deuce.pem" }
    let(:chef_api_key) { File.expand_path(chef_api_key_short) }
    let(:chef_http_client) { double(Chef::REST) }
    let(:entity_name) { config_generator.entity_name }

    let(:exception_404) do
      response = double(Net::HTTPResponse, :code => "404")
      error = Net::HTTPServerException.new(nil, nil)
      error.stub(:response).and_return(response)
      error
    end

    before do
      exception_404

      options.chef_server_url = chef_server_url
      options.chef_username = chef_username
      options.chef_api_key = chef_api_key_short

      Chef::REST.stub(:new).with(chef_server_url, chef_username, chef_api_key).
        and_return(chef_http_client)
    end

    it "has an authenticated Chef HTTP API client" do
      expect(config_generator.chef_api).to eq(chef_http_client)
    end

    it "builds a node using a run_list as a String" do
      options.run_list = "recipe[tmux], role[base]"
      node = config_generator.build_node
      expect(node.run_list).to eq(%w{recipe[tmux] role[base]})
    end

    it "builds a node using a run_list as an Array" do
      options.run_list = %w{recipe[apache2] role[webserver]}
      node = config_generator.build_node
      expect(node.run_list).to eq(%w{recipe[apache2] role[webserver]})
    end

    it "verifies that no node or client exists with the given name" do
      chef_http_client.should_receive(:get).with("nodes/#{entity_name}").
        and_raise(exception_404)
      chef_http_client.should_receive(:get).with("clients/#{entity_name}").
        and_raise(exception_404)
      config_generator.sanity_check
    end

    it "creates a client" do
      client_key = "--rsa private key etc--"
      created_client = Chef::ApiClient.new.tap do |c|
        c.name entity_name
        c.admin false
        c.private_key client_key
      end
      chef_http_client.should_receive(:post).
        with("clients", :name => entity_name, :admin => false).
        and_return(created_client)
      config_generator.create_client
      expect(config_generator.client).to eq(created_client)
      expect(config_generator.files_to_install).to have(1).items
      client_pem = config_generator.files_to_install.first
      expect(client_pem.mode).to eq("0600")
      expect(client_pem.content).to eq(client_key)
      expect(client_pem.rel_path).to eq("client.pem")
    end

    it "uses the client identity to create a node" do
      client_key = "--rsa private key etc--"
      created_client = Chef::ApiClient.new.tap do |c|
        c.name entity_name
        c.admin false
        c.private_key client_key
      end
      config_generator.stub(:client).and_return(created_client)
      Chef::REST.stub(:new).with(chef_server_url, entity_name, nil, :raw_key => client_key).
        and_return(chef_http_client)

      new_node = Chef::Node.build(entity_name)
      # Chef::Node does not define `==` which means that it falls back
      # to object identity, which makes our subsequent `should_receive`
      # fail without a workaround.
      Chef::Node.should_receive(:build).with(entity_name).and_return(new_node)

      chef_http_client.should_receive(:post).
        with("nodes", new_node)

      config_generator.create_node
      expect(config_generator.node).to eq(new_node)
    end
  end

  describe "installing configured files" do
    before do
      config_generator.install_file("testing", "test.sh") do |f|
        f.content = "hello world"
        f.mode = "0600"
      end
    end

    it "generates a random temporary dir to install files to" do
      SecureRandom.should_receive(:hex).with(16).and_call_original
      expect(config_generator.staging_dir).to match(%r|\A/tmp/chef-bootstrap-[0-9a-f]{32}\Z|)
    end

    it "stages files to a temporary location" do
      staging_dir = config_generator.staging_dir
      transport.should_receive(:run).with("mkdir -m 0700 #{staging_dir}")
      transport.should_receive(:scp).with("hello world", "#{staging_dir}/test.sh")
      config_generator.stage_files(transport)
    end

    it "moves staged files to the desired location" do
      staging_dir = config_generator.staging_dir
      transport.should_receive(:run).with("mkdir -m 0700 #{staging_dir}")
      transport.should_receive(:scp).with("hello world", "#{staging_dir}/test.sh")
      config_generator.stage_files(transport)

      create_chef_dir=<<-EOH
bash -c '
  mkdir -p -m 0700 /etc/chef
  chown root:root /etc/chef
  chmod 0755 /etc/chef
'
EOH

      transport.should_receive(:sudo).with(create_chef_dir).and_return("sudo #{create_chef_dir}")
      transport.should_receive(:pty_run).with("sudo #{create_chef_dir}")

      move_staged_file=<<-EOH
bash -c '
  mv #{staging_dir}/test.sh /etc/chef/test.sh
  chown root:root /etc/chef/test.sh
  chmod 0600 /etc/chef/test.sh
'
EOH

      sudo_move_staged_file = "sudo #{move_staged_file}"
      transport.should_receive(:sudo).with(move_staged_file).and_return(sudo_move_staged_file)
      transport.should_receive(:pty_run).with(sudo_move_staged_file)

      config_generator.install_staged_files(transport)
    end
  end


end


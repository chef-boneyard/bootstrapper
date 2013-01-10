require 'spec_helper'

describe Bootstrapper::Config do

  let(:config) { Bootstrapper::Config.new }

  describe "when importing knife config" do
    let(:knife_config) do
      { :ssh_user => "jane",
        :ssh_password => "p@ssword",
        :identity_file => "spec/fixtures/id_rsa",
        :ssh_port => 2222 }
    end

    before do
      config.apply_knife_config(knife_config)
    end

    it "sets the ssh user" do
      expect(config.user).to eq("jane")
    end

    it "sets the ssh password" do
      expect(config.password).to eq("p@ssword")
    end

    it "sets the port" do
      expect(config.port).to eq(2222)
    end

    it "sets the ssh key" do
      expect(config.keys).to eq(File.expand_path("spec/fixtures/id_rsa"))
    end

    context "and host_key_verify is not set" do
      it "does not set paranoid" do
        expect(config.paranoid).to be_nil
      end

      it "does not modify the known hosts config" do
        expect(config.user_known_hosts_file).to be_nil
      end
    end

    context "and host_key_verify is false" do
      before do
        config.apply_knife_config(:host_key_verify => false)
      end

      it "sets paranoid to false" do
        expect(config.paranoid).to be_false
      end

      it "sets the known hosts file to /dev/null" do
        expect(config.user_known_hosts_file).to eq("/dev/null")
      end
    end
  end

  describe "when importing Chef::Config" do
    let(:chef_config) do
      {:knife => { :ssh_user => "jane",
        :ssh_password => "p@ssword",
        :identity_file => "spec/fixtures/id_rsa",
        :ssh_port => 2222 } }
    end

    before do
      config.apply_chef_config(chef_config)
    end

    it "sets the ssh user" do
      expect(config.user).to eq("jane")
    end

    it "sets the ssh password" do
      expect(config.password).to eq("p@ssword")
    end

    it "sets the port" do
      expect(config.port).to eq(2222)
    end

    it "sets the ssh key" do
      expect(config.keys).to eq(File.expand_path("spec/fixtures/id_rsa"))
    end
  end

end

require 'bootstrapper/installers/omnibus'

require 'spec_helper'
require 'shared/installer'

describe Bootstrapper::Installers::Omnibus do
  it_behaves_like "A Chef Installer"

  let(:transport) { double("Transport Object") }
  let(:options) { Bootstrapper::Installers::Omnibus.config_object }
  let(:installer) { Bootstrapper::Installers::Omnibus.new(transport, options) }

  describe "configurable options" do

    it "configures the chef version" do
      expect(Bootstrapper::Installers::Omnibus.options).to include([:bootstrap_version, {}])
    end

  end

  context "when no bootstrap version is specified" do

    it "installs the latest version" do
      expect(installer.install_version).to eq("latest")
    end

    it "generates an install script to run install.sh" do
      expected_script=<<-EXPECTED
set -x
bash <(wget https://www.opscode.com/chef/install.sh -O -) -v latest
EXPECTED
      expect(installer.install_script).to eq(expected_script)
    end

  end

  context "when a specific chef version is specified" do
    before do
      options.bootstrap_version = "11.6.0"
    end

    it "installs the desired version" do
      expect(installer.install_version).to eq("11.6.0")
    end

    it "generates an install script to run install.sh for the desired version" do
      expected_script=<<-EXPECTED
set -x
bash <(wget https://www.opscode.com/chef/install.sh -O -) -v 11.6.0
EXPECTED
      expect(installer.install_script).to eq(expected_script)
    end

  end

  describe "installing chef to the remote machine" do

    let(:config_generator) { double("Config generator object") }
    let(:transport) { double("Transport object") }

    let(:script_desc) { "bootstrap script" }
    let(:script_rel_path) { "bootstrap.sh" }

    let(:transport) { double("Transport object") }

    it "stages the install script to the remote machine" do
      file_spec = Bootstrapper::ConfigGenerator::ConfigFile.new(script_desc, script_rel_path)

      config_generator.should_receive(:install_file).
        with(script_desc, script_rel_path).
        and_yield(file_spec)

      installer.setup_files(config_generator)
      expect(file_spec.content).to eq(installer.install_script)
      expect(file_spec.mode).to eq("0755")
    end

    it "remotely executes the install script" do
      sudo_install = "sudo bash -x /etc/chef/bootstrap.sh"
      transport.should_receive(:sudo).
        with("bash -x /etc/chef/bootstrap.sh").
        and_return(sudo_install)
      transport.should_receive(:pty_run).with(sudo_install)
      installer.install(transport)
    end
  end


end

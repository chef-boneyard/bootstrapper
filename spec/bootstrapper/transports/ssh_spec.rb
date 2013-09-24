require 'spec_helper'
require 'bootstrapper/transports/ssh'

require 'shared/transport'

describe Bootstrapper::Transports::SSH do

  it_should_behave_like "A Transport Implementation"

  let(:ui) { double("Knife UI object") }
  let(:hostname) { "bootstrap-me.example.com" }
  let(:user) { "charlie" }
  let(:password) { "opensesame" }

  let(:options) do
    opts = Bootstrapper::Transports::SSH.config_object
    opts.host = hostname
    opts.user = user
    opts.password = password
    opts
  end

  let(:ssh) { Bootstrapper::Transports::SSH.new(ui, options) }

  describe "setting SSH options" do
    let(:options) { Bootstrapper::Transports::SSH.options }

    it "configures the target host" do
      expect(options).to include([:host, {:type=>:string, :desc=>"The host to bootstrap"}])
    end

    it "configures the user name for login" do
      expect(options).to include([:user, {:type=>:string, :desc=>"User to login as"}])
    end

    it "configures whether to use sudo" do
      expect(options).to include([:sudo, {:type=>:boolean, :desc=>"Use sudo to run as root"}])
    end

    it "configures the SSH password" do
      expect(options).to include([:password, {:type=>:string, :desc=>"The SSH password"}])
    end

    it "configures the SSH port" do
      expect(options).to include([:port, {:type=>:numeric, :desc=>"The SSH port"}])
    end

    it "configures the SSH gateway" do
      pending "Disabled until the feature actually works"
      expect(options).to include([:gateway, {:type=>:string, :desc=>"The SSH gateway to proxy through"}])
    end

    it "configures the identity file (key) to use for authentication" do
      expect(options).to include([:identity_file, {:type=>:string, :desc=>"The SSH identity file used for authentication"}])
    end

    it "configures host key verification" do
      expect(options).to include([:host_key_verify, {:type=>:boolean,:default=>true}])
    end

    it "configures multi-host output mode" do
      expect(options).to include([:multi_host, {:type=>:boolean,:desc=>"Optimize output for multiple hosts"}])
    end
  end

  describe "converting CLI options to Net::SSH compatible options" do

    let(:net_ssh_config) { ssh.net_ssh_config }
    let(:net_ssh_opts) { net_ssh_config[2] }

    it "sets the host" do
      expect(net_ssh_config[0]).to eq("bootstrap-me.example.com")
    end

    it "sets the user" do
      expect(net_ssh_config[1]).to eq("charlie")
    end

    it "sets the password" do
      expect(net_ssh_opts[:password]).to eq("opensesame")
    end

    context "and an identity file is not specified" do
      it "does not set authentication to keys only" do
        expect(net_ssh_opts[:keys_only]).to be_nil
      end
    end

    context "and an identity file is specified" do

      before do
        options.identity_file = "~/.ssh/special_id_rsa"
      end

      it "sets authentication to keys only" do
        expect(net_ssh_opts[:keys_only]).to be_true
      end
    end

    context "and host_key_verify is not set" do
      it "does not set paranoid" do
        expect(net_ssh_opts[:paranoid]).to be_nil
      end

      it "does not modify the known hosts config" do
        expect(net_ssh_opts[:user_known_hosts_file]).to be_nil
      end
    end

    context "and host_key_verify is false" do
      before do
        options.host_key_verify = false
      end

      it "sets paranoid to false" do
        expect(net_ssh_opts[:paranoid]).to be_false
      end

      it "sets the known hosts file to /dev/null" do
        expect(net_ssh_opts[:user_known_hosts_file]).to eq("/dev/null")
      end
    end

    describe "in printable form" do
      it "conceals the password" do
        redacted_opts = ssh.printable_ssh_config[2]
        expect(redacted_opts[:password]).to eq("***Password Concealed***")
      end
    end

  end

  describe "establishing an SSH session" do
    let(:net_ssh_session) { double("Net::SSH:Session") }
    let(:expected_opts) { {:port=>nil, :password=>password} }

    describe "when authentication succeeds the first time" do
      it "yields an SSH session" do
        Net::SSH.should_receive(:start).
          with(hostname, user, expected_opts).
          and_yield(net_ssh_session)

        session = nil

        ssh.connect do |session_object|
          session = session_object
        end
        expect(session).to be_a(Bootstrapper::Transports::SSHSession)
        expect(session.options).to eq(options)
        expect(session.ui).to eq(ui)
        expect(session.session).to eq(net_ssh_session)
      end
    end

    describe "when authentication fails the first time (interactive password auth)" do

      it "asks for a password interactively" do
        Net::SSH.should_receive(:start).
          with(hostname, user, expected_opts).
          and_raise(Net::SSH::AuthenticationFailed, "charlie")

        ui.should_receive(:msg).
          with("Authentication failed for charlie")
        ui.should_receive(:ask).
          with("login password for charlie@bootstrap-me.example.com:").
          and_return("correct-password")

        updated_ssh_opts = expected_opts.dup
        updated_ssh_opts[:password] = "correct-password"

        Net::SSH.should_receive(:start).
          with(hostname, user, updated_ssh_opts).
          and_yield(net_ssh_session)

        session = nil

        ssh.connect do |session_object|
          session = session_object
        end
        expect(session).to be_a(Bootstrapper::Transports::SSHSession)
        expect(session.options).to eq(options)
        expect(session.ui).to eq(ui)
        expect(session.session).to eq(net_ssh_session)
      end
    end

  end

end

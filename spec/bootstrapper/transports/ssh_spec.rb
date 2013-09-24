require 'spec_helper'
require 'bootstrapper/transports/ssh'

# TODO:
# require 'shared/transport'

describe Bootstrapper::Transports::SSH do

  # TODO:
  # it_should_behave_like "A Transport Implementation"

  ##
  # Salvaged from old config class...
  # context "and host_key_verify is not set" do
  #   it "does not set paranoid" do
  #     expect(config.paranoid).to be_nil
  #   end

  #   it "does not modify the known hosts config" do
  #     expect(config.user_known_hosts_file).to be_nil
  #   end
  # end

  # context "and host_key_verify is false" do
  #   before do
  #     config.apply_knife_config(:host_key_verify => false)
  #   end

  #   it "sets paranoid to false" do
  #     expect(config.paranoid).to be_false
  #   end

  #   it "sets the known hosts file to /dev/null" do
  #     expect(config.user_known_hosts_file).to eq("/dev/null")
  #   end
  # end
end

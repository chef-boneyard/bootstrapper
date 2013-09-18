require 'spec_helper'
require 'bootstrapper/component_options'

describe Bootstrapper::ComponentOptions do

  let(:extended_class) { Class.new { extend Bootstrapper::ComponentOptions } }

  it "accepts Thor compatible options specification" do
    extended_class.option :ssh_port,
                          :desc => "The ssh port",
                          :type => :numeric,
                          :required => true
    expect(extended_class.options).to include([:ssh_port, { :desc => "The ssh port",
                                                          :type => :numeric,
                                                          :required => true}])
  end

  context "with several options defined" do

    before do
      extended_class.option :ssh_port,
                            :desc => "The ssh port",
                            :type => :numeric,
                            :required => true

      extended_class.option :identity_file,
                            :desc => "The SSH identity file used for authentication",
                            :required => true

    end

    it "creates a struct class with fields for those options" do
      config_object = extended_class.config_object
      expect(config_object).to respond_to(:ssh_port)
      expect(config_object).to respond_to(:ssh_port=)
      expect(config_object).to respond_to(:identity_file=)
      expect(config_object).to respond_to(:identity_file)
    end

  end
end


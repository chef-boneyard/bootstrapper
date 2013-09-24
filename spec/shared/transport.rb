require 'spec_helper'

shared_examples_for "A Transport Implementation" do

  let(:ui) { double("UI Object") }
  let(:options) { double("Options object") }
  let(:transport) { described_class.new(ui, options) }

  it "initializes with a ui object" do
    expect(transport.ui).to eq(ui)
  end

  it "initializes with an options object" do
    expect(transport.options).to eq(options)
  end

  it "implements #connect" do
    expect(transport).to respond_to(:connect)
  end
end


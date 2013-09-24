require 'spec_helper'

shared_examples_for "A Transport Session" do

  let(:options) { double("Options object") }
  let(:ui) { double("UI Object") }
  let(:implementation_session) { double("Implementation session object") }
  let(:transport_session) { described_class.new(ui, implementation_session, options) }

  it "initializes with a UI object" do
    expect(transport_session.ui).to eq(ui)
  end

  it "initializes with an options object" do
    expect(transport_session.options).to eq(options)
  end

  it "implements scp" do
    expect(transport_session).to respond_to(:scp)
  end

  it "implements pty_run" do
    expect(transport_session).to respond_to(:pty_run)
  end

  it "implements sudo" do
    expect(transport_session).to respond_to(:sudo)
  end

end

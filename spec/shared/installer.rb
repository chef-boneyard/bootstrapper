
shared_examples_for "A Chef Installer" do

  let(:transport) { double("Transport Object") }
  let(:options) { double("Options Object") }
  let(:installer) { described_class.new(transport, options) }

  it "declares a short name" do
    expect(described_class.short_name).to_not be_nil
  end

  it "initializes with a transport object" do
    expect(installer.transport).to eql(transport)
  end

  it "initializes with an options object" do
    expect(installer.options).to eql(options)
  end

  it "implements #install" do
    expect(installer).to respond_to(:install)
  end

  it "implements #setup_files" do
    expect(installer).to respond_to(:setup_files)
  end
end


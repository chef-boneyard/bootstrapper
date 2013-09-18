
shared_examples_for "A Chef Installer" do

  let(:basic_transport) { double("Transport Object") }

  it "declares a short name" do
    expect(described_class.short_name).to_not be_nil
  end

  it "initializes with a transport object" do
    new_installer = described_class.new(basic_transport)
    expect(new_installer.transport).to eql(basic_transport)
  end

  it "implements :install" do
    expect(installer).to respond_to(:install)
  end
end


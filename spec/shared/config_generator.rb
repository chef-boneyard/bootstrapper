shared_examples_for "A Config Generator" do
  let(:options) { double("Options object") }
  let(:ui) { double("UI Object") }
  let(:config_generator) { described_class.new(ui, options) }

  it "has the UI object" do
    expect(config_generator.ui).to eq(ui)
  end

  it "has its options" do
    expect(config_generator.options).to eq(options)
  end

  it "keeps a list of files to install" do
    expect(config_generator.files_to_install).to be_empty
  end

  it "implements a prepare method" do
    expect(config_generator).to respond_to(:prepare)
  end

  it "implements an install_config method" do
    expect(config_generator).to respond_to(:install_config)
  end

  describe "when adding a file to the list of config files" do
    before do
      config_generator.install_file('data bag secret', "secret.pem") do |file|
        file.content = "a bunch of gibberish"
        file.mode = "0600"
      end
    end

    it "describes the files content and permissions" do
      expect(config_generator.files_to_install).to have(1).item
      file = config_generator.files_to_install.first
      expect(file.description).to eq("data bag secret")
      expect(file.rel_path).to eq("secret.pem")
      expect(file.content).to eq("a bunch of gibberish")
      expect(file.mode).to eq("0600")
    end
  end
end

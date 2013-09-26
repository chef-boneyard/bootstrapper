Bootstrapper.define(:example) do |bootstrap|
  bootstrap.desc = "Null bootstrap definition for testing"

  bootstrap.transport(:test_transport) do |t|
    t.transport_opt = "testing"
  end

  bootstrap.installer(:test_installer) do |i|
    i.installer_opt = "testing"
  end

  bootstrap.config_generator(:test_config_generator) do |c|
    c.config_generator_opt = "testing"
  end
end

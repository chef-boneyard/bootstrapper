# Example of what a bootstrap definition might look like...
Bootstrapper.define(:standard) do |bootstrap|
  bootstrap.desc = "UNIX/SSH bootstrap"
  bootstrap.transport = :ssh
  bootstrap.installer = :omnnibus
  bootstrap.config_generator = :chef_client
end


# Example of what a bootstrap definition might look like...
Bootstrapper.define(:standard) do |bootstrap|
  bootstrap.desc = "UNIX/SSH bootstrap"
  bootstrap.transport(:ssh) do |ssh|
    ssh.host = "192.168.99.134"
    ssh.user = "ddeleo"
    ssh.sudo = true
    ssh.port = 22
    ssh.multi_host = false
  end
  bootstrap.installer(:omnibus) do |pkg|
    pkg.bootstrap_version = "11.6.0"
  end
  bootstrap.config_generator(:chef_client) do |chef|
    chef.chef_server_url = "https://api.opscode.com/organizations/chef-oss-dev"
    chef.chef_username = "kallistec"
    chef.chef_api_key = "~/.chef/kallistec.pem"
  end
end


require 'bootstrapper/config_generator'
module Bootstrapper

  # == Bootstrapper::ChefClient
  # Manages a collection of file descriptions to be installed on the remote
  # node, and installs them via scp+ssh.
  #
  # Files are installed in a two stage process. First, files are staged to a
  # staging directory in /tmp, then they are moved to the final location in
  # /etc/chef.
  class ChefClient < ConfigGenerator

    short_name(:chef_client)

    # TODO: extract code to here from base as necessary

  end

end

module Bootstrapper

  def self.define(bootstrap_strategy_name, &block)
    Definition.create(bootstrap_strategy_name, &block)
  end
end

# Load Core/Base classes:
require 'bootstrapper/config'
require 'bootstrapper/installer'
require 'bootstrapper/config_generator'
require 'bootstrapper/controller'
require 'bootstrapper/definition'

# Default drivers that we're hardcoding for now
require 'bootstrapper/installer/omnibus'
require 'bootstrapper/transport/ssh'
require 'bootstrapper/config_generators/chef_client'

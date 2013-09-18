require 'spec_helper'
require 'bootstrapper/installer'
require 'shared/installer.rb'

describe Bootstrapper::Installer do

  let(:transport) { double("Transport Object") }
  let(:installer) { Bootstrapper::Installer.new(transport) }

  include_examples "A Chef Installer"

end


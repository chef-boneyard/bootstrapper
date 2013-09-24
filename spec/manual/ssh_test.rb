# ssh_test.rb
# USAGE: ruby spec/manual/ssh_test.rb
#
# This script manually configures a Bootstrapper::Transports::SSH object
# and runs it.

################################################################################
# Boilerplate
################################################################################
lib_dir = File.expand_path("../../../lib", __FILE__)
require 'chef/knife/core/ui'
$:.unshift(lib_dir)
require 'bootstrapper/transports/ssh'

################################################################################
# Configuration:
# Configure this to point at a running VM.
################################################################################

options = Bootstrapper::Transports::SSH.config_object
options.port = 22
options.host = "192.168.99.134"
options.user = "ddeleo"
options.sudo = true
options.password = "WRONG"

ui = Chef::Knife::UI.new($stdout, $stderr, $stdin, {}) 

ssh = Bootstrapper::Transports::SSH.new(ui, options)
Chef::Log.init($stderr)
Chef::Log.level = :info

################################################################################
# Run
# Connect to the remote and run some commands
################################################################################
ssh.connect do |session|
  session.pty_run("id")

  session.scp("hello world", "/tmp/hello")
  session.pty_run(session.sudo("date"))
  session.pty_run("sleep 2")
  session.pty_run("cat /tmp/hello")
  session.pty_run(session.sudo("date"))
end


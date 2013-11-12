$:.unshift(File.dirname(__FILE__) + '/lib')
require 'bootstrapper/version'

Gem::Specification.new do |s|
  s.name = 'bootstrapper'
  s.version = Bootstrapper::VERSION
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ['README.md', 'LICENSE' ]
  s.summary = 'A systems integration framework, built to bring the benefits of configuration management to your entire infrastructure.'
  s.description = s.summary
  s.author = 'Dan DeLeo'
  s.email = 'dan@opscode.com'
  s.homepage = 'http://wiki.opscode.com/display/chef'

  s.add_development_dependency 'rspec'
  s.add_dependency 'chef'
  s.add_dependency 'net-ssh'
  s.add_dependency 'net-scp'
  s.add_dependency 'thor'

  s.bindir       = "bin"
  s.executables  = %w( bootstrap )

  s.require_path = 'lib'
  s.files = %w(Rakefile LICENSE README.md) + Dir.glob("{distro,lib,tasks,spec}/**/*", File::FNM_DOTMATCH).reject {|f| File.directory?(f) }
end

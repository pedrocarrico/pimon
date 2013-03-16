# encoding: UTF-8
$: << File.expand_path('./lib')
require 'pimon/version'

Gem::Specification.new do |s|
  s.name        = "pimon"
  s.version     = Pimon::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ 'Pedro Carriço' ]
  s.email       = [ 'pedro.carrico@gmail.com' ]
  s.homepage    = 'http://pimon.pedrocarrico.net/'
  s.summary     = 'Pimon - Raspberry Pi server monitor'
  s.description = 'Pimon is a simple server monitor designed for the Raspberry Pi.'
  s.post_install_message = 'Thank you for using Pimon :-)'
  
  s.required_ruby_version = '>= 1.9'
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/pimon`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  
  s.add_runtime_dependency     'haml',              '~> 4.0.0'
  s.add_runtime_dependency     'sinatra',           '~> 1.4.1'
  s.add_runtime_dependency     'em-websocket',      '= 0.3.8'
  s.add_runtime_dependency     'sinatra-websocket', '~> 0.2.1'
  s.add_runtime_dependency     'sys-uptime',        '~> 0.6.1'
  s.add_runtime_dependency     'thin',              '~> 1.5.0'
  
  s.add_development_dependency 'rack-test',       '~> 0.6.2'
  s.add_development_dependency 'rspec',           '~> 2.13.0'
  s.add_development_dependency 'simplecov',       '~> 0.7.1'
  s.add_development_dependency 'simplecov-rcov',  '~> 0.2.3'
  s.add_development_dependency 'timecop',         '~> 0.6.1'
end

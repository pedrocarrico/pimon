# encoding: UTF-8
$: << File.expand_path('./lib')
require 'pimon/version'

Gem::Specification.new do |s|
  s.name        = "pimon"
  s.version     = Pimon::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ 'Pedro Carriço' ]
  s.email       = [ 'pedro.carrico@gmail.com' ]
  s.homepage    = 'http://pimon.pedrocarrico.net/'
  s.summary     = 'Pimon - Raspberry Pi server monitor'
  s.description = 'Pimon is a simple server monitor designed for the Raspberry Pi. It uses redis lists to keep the latest observed statistics and also uses highcharts to display some nice charts on your web browser.'
  
  s.required_ruby_version = ">= 1.9"
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/pimon`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency     "bundler"
  s.add_runtime_dependency     "haml",       "= 3.1.7"
  s.add_runtime_dependency     "redis",      "= 3.0.1"
  s.add_runtime_dependency     "sinatra",    "= 1.3.2"
  s.add_runtime_dependency     "thin",       "= 1.4.1"
  
  s.add_development_dependency "rack-test",  ">= 0"
  s.add_development_dependency "mock_redis", ">= 0.5.0"
  s.add_development_dependency "rspec", ">= 2.11.0"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "simplecov-rcov"
  s.add_development_dependency "timecop"
end

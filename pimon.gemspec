require_relative 'lib/pimon/version'

Gem::Specification.new do |s|
  s.name        = 'pimon'
  s.version     = Pimon::VERSION
  s.licenses    = ['WTFPL']
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Pedro Carriço']
  s.email       = ['pedro.carrico@gmail.com']
  s.homepage    = 'http://pimon.pedrocarrico.net/'
  s.summary     = 'Pimon - Raspberry Pi server monitor'
  s.description = 'Pimon is a simple server monitor designed for the Raspberry Pi.'
  s.post_install_message = 'Thank you for using Pimon :-)'

  s.required_ruby_version = '>= 1.9'

  s.files         = Dir.glob('{lib,config}/**/*') << 'pimon.gemspec'
  s.test_files    = Dir.glob('{test,spec,features}/**/*')
  s.executables   = 'pimon'
  s.require_paths = ['lib']

  s.add_runtime_dependency 'haml',           '= 4.0.7'
  s.add_runtime_dependency 'sinatra',        '= 1.4.6'
  s.add_runtime_dependency 'faye-websocket', '= 0.10.0'
  s.add_runtime_dependency 'sys-uptime',     '= 0.6.2'
  s.add_runtime_dependency 'thin',           '= 1.6.3'

  s.add_development_dependency 'rack-test',      '= 0.6.2'
  s.add_development_dependency 'rspec',          '= 3.0.0'
  s.add_development_dependency 'rubocop',        '=0.33.0'
  s.add_development_dependency 'simplecov',      '= 0.10.0'
  s.add_development_dependency 'simplecov-rcov', '= 0.2.3'
  s.add_development_dependency 'timecop',        '= 0.7.1'
  s.add_development_dependency 'coveralls',      '= 0.8.2'
  s.add_development_dependency 'pry',            '= 0.10.0'
end

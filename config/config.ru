if ENV['RACK_ENV'] == 'development'
  require 'rubygems'
  require 'bundler'

  Bundler.require
end

require_relative '../lib/pimon'

$PROGRAM_NAME = 'pimon'

run Pimon::App

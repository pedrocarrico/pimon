# Set environment does not set RACK_ENV if required before Sinatra
# Check http://richardconroy.blogspot.pt/2010/01/issues-testing-sinatra-datamapper-app.html
ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), '..', 'pimon.rb')

require 'sinatra'
require 'rack/test'

# setup test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

def app
  Pimon
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

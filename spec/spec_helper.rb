# Set environment does not set RACK_ENV if required before Sinatra
# Check http://richardconroy.blogspot.pt/2010/01/issues-testing-sinatra-datamapper-app.html
ENV['RACK_ENV'] = 'test'

if ENV['COVERAGE']
  require 'simplecov'
  require 'simplecov-rcov'
  class SimpleCov::Formatter::MergedFormatter
    def format(result)
      SimpleCov::Formatter::HTMLFormatter.new.format(result)
      SimpleCov::Formatter::RcovFormatter.new.format(result)
    end
  end
  SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter
  SimpleCov.start
end

require File.join(File.dirname(__FILE__), '..', 'pimon.rb')

require 'sinatra'
require 'rack/test'

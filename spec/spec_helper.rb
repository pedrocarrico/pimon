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
  SimpleCov.start do
    add_filter 'spec'
  end
end

require File.join(File.dirname(__FILE__), '..', 'lib', 'pimon.rb')

require 'sinatra'
require 'rack/test'

# Disable the `should` syntax...as explained here:
# http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
RSpec.configure do |config|
  config.order = :random
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

require 'spec_helper'

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

describe "Pimon" do
  it "should be success" do
    
    get '/'
    expect(last_response).to be_ok
  end
end

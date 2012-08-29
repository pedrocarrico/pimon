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
  context "when not authenticated" do
    
    it "should be not authorized" do
      get '/'
      last_response.status.should == 401
    end
  end
  
  context "when authenticated" do
    before { authorize 'pimon', 'pimon' }
    
    it "should be success" do
      
      get '/'
      last_response.should be_ok
    end
  end
end

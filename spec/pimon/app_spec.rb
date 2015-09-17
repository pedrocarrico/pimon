require 'spec_helper'

# setup test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

def app
  Pimon::App
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

describe Pimon::App do
  describe 'GET /' do
    before { get '/' }

    it 'renders the index page' do
      expect(last_response).to be_ok
      expect(last_response.body).to include('test_hostname')
    end
  end
end

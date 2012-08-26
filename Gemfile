source :rubygems

gem 'capistrano'
gem 'haml'
gem 'redis'
gem "sinatra", :require => "sinatra/base"
gem 'thin'

gem 'pry', :group => [:development, :test]

group :test do
  # mock_redis 0.4.1 from rubygems is currently broken on the pipelined method
  gem 'mock_redis', :git => 'git://github.com/causes/mock_redis.git'
  gem 'rspec'
  gem 'rack-test'
end

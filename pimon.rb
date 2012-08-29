require 'bundler/setup'

require 'active_support/core_ext/hash/indifferent_access'
require 'haml'
require "#{File.dirname(__FILE__)}/lib/pimon_config"
require "#{File.dirname(__FILE__)}/lib/stats_collector"
require 'sinatra'

class Pimon < Sinatra::Base
  configure :development, :production do
    require 'redis'
    config = PimonConfig.create_new(ENV['RACK_ENV'])
    
    if config.is_basic_auth_enabled?
      use Rack::Auth::Basic, "Restricted Area" do |username, password|
        [username, password] == config.basic_auth
      end
    end
    
    set :public_folder, 'public'
    set :config, config
    set :stats_checker, StatsCollector.new(config, Redis.new(:path => config.redis['socket']))
  end
  
  configure :test do
    require 'mock_redis'
    
    config = PimonConfig.create_new('test')
    
    if config.is_basic_auth_enabled?
      use Rack::Auth::Basic, "Restricted Area" do |username, password|
        [username, password] == config.basic_auth
      end
    end
    set :public_folder, 'public'
    set :config, config
    set :stats_checker, StatsCollector.new(config, MockRedis.new)
  end
  
  get '/' do
    last_update = settings.stats_checker.last_update
    last_modified(last_update) if ENV['RACK_ENV'] != 'development' && last_update
    
    @o = HashWithIndifferentAccess.new
    @o[:time] = HashWithIndifferentAccess.new
    @o.merge!(settings.config.chart)
    @o[:time][:stats], @o[:cpu][:stats], @o[:mem][:stats], @o[:swap][:stats] = settings.stats_checker.show_stats
    
    haml :index
  end
end

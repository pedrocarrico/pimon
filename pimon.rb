require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'])
require 'haml'
require "#{File.dirname(__FILE__)}/lib/pimon_config"
require "#{File.dirname(__FILE__)}/lib/stats_collector"
require 'sinatra'

class Pimon < Sinatra::Base
  def self.configure_basic_auth
    if settings.config.is_basic_auth_enabled?
      use Rack::Auth::Basic, "Restricted Area" do |username, password|
        [username, password] == config.basic_auth
      end
    end
  end
  
  configure :development, :production do
    require 'redis'
    
    config = PimonConfig.create_new(ENV['RACK_ENV'])
    
    EventMachine::next_tick do
      settings.timer = EventMachine::add_periodic_timer(config.stats[:time_period_in_min] * 60) do
        settings.stats_checker.collect_stats
      end
    end
    
    set :public_folder, 'public'
    set :config, config
    set :stats_checker, StatsCollector.new(config, Redis.new(:path => config.redis[:socket]))
    set :timer, nil
    
    self.configure_basic_auth
  end
  
  configure :test do
    require 'mock_redis'
    
    config = PimonConfig.create_new('test')
    
    set :public_folder, 'public'
    set :config, config
    set :stats_checker, StatsCollector.new(config, MockRedis.new)
    set :timer, nil
    
    self.configure_basic_auth
  end
  
  get '/' do
    last_update = settings.stats_checker.last_update
    last_modified(last_update) if ENV['RACK_ENV'] != 'development' && last_update
    
    @o = settings.stats_checker.show_stats
    
    haml :index
  end
end

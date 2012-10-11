$: << File.dirname(__FILE__)

if File.file?('Gemfile')
  require 'bundler/setup'
  Bundler.require(:default, ENV['RACK_ENV'])
end
require 'eventmachine'
require 'json'
require 'haml'
require 'pimon/pimon_config'
require 'pimon/stats_collector'
require 'sinatra'
require 'sinatra-websocket'

class Pimon < Sinatra::Base
  set :public_folder, "#{File.dirname(__FILE__)}/pimon/public"
  set :views,         "#{File.dirname(__FILE__)}/pimon/views"
  set :sockets, []
  
  def self.configure_basic_auth
    if settings.config.is_basic_auth_enabled?
      use Rack::Auth::Basic, "Restricted Area" do |username, password|
        [username, password] == config.basic_auth
      end
    end
  end
  
  configure :development, :production do
    require 'redis'
    filename = "#{File.dirname(__FILE__)}/../config/default.yml"
    config = PimonConfig.create_new(ENV['PIMON_CONFIG'] || filename)
    
    EventMachine::next_tick do
      settings.timer = EventMachine::add_periodic_timer(config.stats[:time_period_in_min] * 60) do
        settings.stats_checker.collect_stats
        @stats = settings.stats_checker.show_stats
        
        settings.sockets.each{ |s| s.send(@stats) }
      end
    end
    
    set :config, config
    set :stats_checker, StatsCollector.new(config, Redis.new(:path => config.redis[:socket]))
    set :timer, nil
    
    self.configure_basic_auth
  end
  
  configure :test do
    require 'mock_redis'
    
    config = PimonConfig.create_new("#{File.dirname(__FILE__)}/../config/test.yml")
    
    set :config, config
    set :stats_checker, StatsCollector.new(config, MockRedis.new)
    set :timer, nil
    
    self.configure_basic_auth
  end
  
  get '/' do
    if !request.websocket?
      last_update = settings.stats_checker.last_update
      last_modified(last_update) if ENV['RACK_ENV'] != 'development' && last_update
      
      haml :index
    else
      request.websocket do |ws|
        ws.onopen do
          settings.sockets << ws
          @stats ||= settings.stats_checker.show_stats
          ws.send(@stats)
        end
        ws.onmessage do |msg|
          puts "message received!! -> #{msg}"
        end
        ws.onclose do
          settings.sockets.delete(ws)
        end
      end
    end
  end
end

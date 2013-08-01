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

  configure :development, :production do
    filename = "#{File.dirname(__FILE__)}/../config/default.yml"
    config = PimonConfig.create_new(ENV['PIMON_CONFIG'] || filename)
    
    EventMachine::next_tick do
      settings.timer = EventMachine::add_periodic_timer(config.stats[:time_period_in_secs]) do
        settings.stats_checker.collect_stats
        @stats = settings.stats_checker.show_stats
        
        settings.sockets.each{ |s| s.send(@stats) }
      end
    end
    
    set :config, config
    set :stats_checker, StatsCollector.new(config)
    set :timer, nil
    
    settings.stats_checker.collect_stats
    @stats = settings.stats_checker.show_stats
  end
  
  configure :test do
    config = PimonConfig.create_new("#{File.dirname(__FILE__)}/../config/test.yml")
    
    set :config, config
    set :stats_checker, StatsCollector.new(config)
    set :timer, nil
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

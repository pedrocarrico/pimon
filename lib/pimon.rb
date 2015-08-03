require 'eventmachine'
require 'json'
require 'haml'
require 'sinatra'
require 'faye/websocket'

Faye::WebSocket.load_adapter('thin')

require_relative 'pimon/pimon_config'
require_relative 'pimon/stats_collector'

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
  end

  configure :test do
    config = PimonConfig.create_new("#{File.dirname(__FILE__)}/../config/test.yml")
    
    set :config, config
    set :stats_checker, StatsCollector.new(config)
    set :timer, nil
  end

  get '/' do
    if Faye::WebSocket.websocket?(request.env)
      ws = Faye::WebSocket.new(request.env)

      ws.on(:open) do
        settings.sockets << ws
        @stats ||= settings.stats_checker.show_stats
        ws.send(@stats)
      end

      ws.on(:close) do
        settings.sockets.delete(ws)
      end

      ws.rack_response
    else
      last_update = settings.stats_checker.last_update
      last_modified(last_update) if ENV['RACK_ENV'] != 'development' && last_update

      haml :index
    end
  end
end

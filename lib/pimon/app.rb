require 'eventmachine'
require 'json'
require 'haml'
require 'sinatra'
require 'faye/websocket'

require 'pimon/config'
require 'pimon/stats_collector'

Faye::WebSocket.load_adapter('thin')

module Pimon
  class App < Sinatra::Base
    set :public_folder, "#{File.dirname(__FILE__)}/public"
    set :views,         "#{File.dirname(__FILE__)}/views"
    set :connected_websockets, []

    configure :development, :production do
      filename = "#{File.dirname(__FILE__)}/../../config/default.yml"
      config = Pimon::Config.load(ENV['PIMON_CONFIG'] || filename)

      set :config, config
      set :stats_collector, Pimon::StatsCollector.new(config)
      set :timer, nil
    end

    configure :test do
      config = Pimon::Config.load("#{File.dirname(__FILE__)}/../../config/test.yml")

      set :config, config
      set :stats_collector, Pimon::StatsCollector.new(config)
      set :timer, nil
    end

    def initialize(*args, &bk)
      super
      start_collecting_stats
      self
    end

    get '/' do
      locals = {
        charts: settings.stats_collector.charts,
        single_stats: settings.stats_collector.single_stats,
        hostname: settings.config.hostname
      }

      haml :index, locals: locals
    end

    get '/stats' do
      if Faye::WebSocket.websocket?(request.env)
        websocket = Faye::WebSocket.new(request.env)

        websocket.on(:open) do
          settings.connected_websockets << websocket
          websocket.send(settings.stats_collector.show_stats.to_json)
        end

        websocket.on(:close) do
          settings.connected_websockets.delete(websocket)
        end

        websocket.rack_response
      else
        halt 404
      end
    end

    def start_collecting_stats
      return if settings.test?
      settings.stats_collector.collect_stats
      EventMachine.next_tick do
        settings.timer = EventMachine.add_periodic_timer(settings.config.stats['time_period_in_secs']) do
          settings.stats_collector.collect_stats
          settings.connected_websockets.each { |s| s.send(settings.stats_collector.show_stats.to_json) }
        end
      end
    end
  end
end

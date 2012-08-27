require 'bundler/setup'

require 'date'
require 'haml'
require "#{File.dirname(__FILE__)}/lib/queues"
require 'sinatra'
require 'redis'
require 'yaml'

class Pimon < Sinatra::Base

  configure :development, :production do
    config = YAML.load_file("#{File.dirname(__FILE__)}/config/#{ENV['RACK_ENV'] || "development"}.yml")
    
    if config['basic_auth']['enabled']
      use Rack::Auth::Basic, "Restricted Area" do |username, password|
        [username, password] == [config['basic_auth']['username'], config['basic_auth']['password']]
      end
    end
    
    set :public_folder, 'public'
    set :redis, Redis.new(:path => config['redis']['socket'])
    set :config, config
  end
  
  configure :test do
    require 'mock_redis'
    
    config = YAML.load_file("#{File.dirname(__FILE__)}/config/test.yml")
    
    if config['basic_auth']['enabled']
      use Rack::Auth::Basic, "Restricted Area" do |username, password|
        [username, password] == [config['basic_auth']['username'], config['basic_auth']['password']]
      end
    end
    set :public_folder, 'public'
    set :redis, MockRedis.new
    set :config, config
  end
  
  get '/' do
    last_update = settings.redis.lindex(Queues::TIME, 5)
    last_modified(DateTime.parse(last_update)) if ENV['RACK_ENV'] != 'development' && last_update
    
    @o = {}
    
    @o[:time] = {}
    @o[:cpu] = {}
    @o[:mem] = {}
    @o[:swap] = {}
    
    @o[:cpu][:color] = settings.config['chart']['cpu']['color']
    @o[:mem][:color] = settings.config['chart']['mem']['color']
    @o[:swap][:color] = settings.config['chart']['swap']['color']
    
    @o[:time][:stats], @o[:cpu][:stats], @o[:mem][:stats], @o[:swap][:stats] = settings.redis.pipelined do
      settings.redis.lrange(Queues::TIME, 0, -1)
      settings.redis.lrange(Queues::CPU,  0, -1)
      settings.redis.lrange(Queues::MEM,  0, -1)
      settings.redis.lrange(Queues::SWAP, 0, -1)
    end
    
    @o[:time][:stats] = @o[:time][:stats].reduce([]){ |acc, value| acc << (/\d\d:\d\d:\d\d/.match(value))[0]}
    @o[:cpu][:stats]  = @o[:cpu][:stats].reduce([]){ |acc, value| acc << value.to_i}
    @o[:mem][:stats]  = @o[:mem][:stats].reduce([]){ |acc, value| acc << value.to_i}
    @o[:swap][:stats] = @o[:swap][:stats].reduce([]){ |acc, value| acc << value.to_i}
    
    haml :index
  end
end

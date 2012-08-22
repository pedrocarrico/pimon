require 'date'
require 'haml'
require "#{File.dirname(__FILE__)}/lib/queues"
require 'sinatra'
require 'redis'
require 'yaml'

configure do
  config = YAML.load_file("#{File.dirname(__FILE__)}/config/#{ENV['RACK_ENV'] || "development"}.yml")
  
  if config['basic_auth']['enabled']
    use Rack::Auth::Basic, "Restricted Area" do |username, password|
      [username, password] == [config['basic_auth']['username'], config['basic_auth']['password']]
    end
  end
  
  set :public_folder, 'public'
  set :redis, Redis.new(:path => config['redis']['socket'])
end

get '/' do
  last_update = settings.redis.lindex(Queues::TIME, 5)
  last_modified(DateTime.parse(last_update)) if last_update
  
  @time, @cpu, @mem, @swap = settings.redis.pipelined do
    settings.redis.lrange(Queues::TIME, 0, -1)
    settings.redis.lrange(Queues::CPU,  0, -1)
    settings.redis.lrange(Queues::MEM,  0, -1)
    settings.redis.lrange(Queues::SWAP, 0, -1)
  end
  
  @time = @time.reduce([]){ |acc, value| acc << (/\d\d:\d\d:\d\d/.match(value))[0]}
  @cpu  = @cpu.reduce([]){ |acc, value| acc << value.to_i}
  @mem  = @mem.reduce([]){ |acc, value| acc << value.to_i}
  @swap = @swap.reduce([]){ |acc, value| acc << value.to_i}
  
  haml :index
end

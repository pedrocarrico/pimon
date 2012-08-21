require 'haml'
require "#{File.dirname(__FILE__)}/lib/queues"
require 'sinatra'
require 'redis'
require 'yaml'

configure do
  config = YAML.load_file('config.yml')
  
  if config['basic_auth']['enabled']
    use Rack::Auth::Basic, "Restricted Area" do |username, password|
      [username, password] == [config['basic_auth']['username'], config['basic_auth']['password']]
    end
  end
  
  set :public_folder, 'public'
  set :redis, Redis.new(:path => config['redis']['socket'])
end

get '/' do
  @time, @cpu, @mem, @swap = settings.redis.pipelined do
    settings.redis.lrange(Queues::TIME, 0, -1)
    settings.redis.lrange(Queues::CPU,  0, -1)
    settings.redis.lrange(Queues::MEM,  0, -1)
    settings.redis.lrange(Queues::SWAP, 0, -1)
  end
  
  @cpu  = @cpu.reduce([]){ |acc, value| acc << value.to_i}
  @mem  = @mem.reduce([]){ |acc, value| acc << value.to_i}
  @swap = @swap.reduce([]){ |acc, value| acc << value.to_i}
  
  haml :index
end

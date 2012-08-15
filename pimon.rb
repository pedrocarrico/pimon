require 'haml'
require 'sinatra'
require 'redis'

set :public_folder, 'public'
set :redis, Redis.new(:path => '/tmp/redis.sock')

TIME_QUEUE = 'pimon_time'

CPU_USR_QUEUE = 'pimon_cpu_usr'
CPU_SYS_QUEUE = 'pimon_cpu_sys'
CPU_IDL_QUEUE = 'pimon_cpu_idl'

get '/' do
  @time, @usr, @sys, @idl = settings.redis.pipelined do
    settings.redis.lrange(TIME_QUEUE, 0, -1)
    settings.redis.lrange(CPU_USR_QUEUE, 0, -1)
    settings.redis.lrange(CPU_SYS_QUEUE, 0, -1)
    settings.redis.lrange(CPU_IDL_QUEUE, 0, -1)
  end

  @usr = @usr.reduce([]){ |acc, value| acc << value.to_i}
  @sys = @sys.reduce([]){ |acc, value| acc << value.to_i}
  @idl = @idl.reduce([]){ |acc, value| acc << value.to_i}

  haml :index
end

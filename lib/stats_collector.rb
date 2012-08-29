require 'bundler/setup'

require 'date'

class StatsCollector
  def initialize(config, redis)
    @config = config
    @redis = redis
    @number_of_checks = config.stats[:slices]
  end
  
  def check_stats
    cpu_idle = vmstat[3].split(" ")[14].to_i
    
    ram = free[1].split(" ")
    swap = free[2].split(" ")
    
    mem_total  = ram[1].to_i
    mem_used   = ram[2].to_i
    swap_total = swap[1].to_i
    swap_used  = swap[2].to_i
    
    [ 100 - cpu_idle , ((mem_used.to_f / mem_total) * 100).to_i, ((swap_used.to_f / swap_total) * 100).to_i ]
  end
  
  def collect_stats
    queue_size = @redis.llen(@config.queues[:time])
    
    @redis.pipelined do
      if queue_size == @number_of_checks
        pop_old_stats
      end
      
      cpu_usage, mem_usage, swap_usage = check_stats
      
      @redis.rpush(@config.queues[:time], Time.now.strftime("%Y-%m-%d %H:%M:%S"))
      @redis.rpush(@config.queues[:cpu], cpu_usage)
      @redis.rpush(@config.queues[:mem], mem_usage)
      @redis.rpush(@config.queues[:swap], swap_usage)
    end
  end
  
  def last_update
    time = @redis.lindex(@config.queues[:time], @config.stats[:slices] - 1)
    
    DateTime.parse(time) if time
  end
  
  def show_stats
    time, cpu, mem, swap = @redis.pipelined do
      @redis.lrange(@config.queues[:time], 0, -1)
      @redis.lrange(@config.queues[:cpu],  0, -1)
      @redis.lrange(@config.queues[:mem],  0, -1)
      @redis.lrange(@config.queues[:swap], 0, -1)
    end
    
    time = time.reduce([]){ |acc, value| acc << (/\d\d:\d\d:\d\d/.match(value))[0]}
    cpu  = cpu.reduce([]){ |acc, value| acc << value.to_i}
    mem  = mem.reduce([]){ |acc, value| acc << value.to_i}
    swap = swap.reduce([]){ |acc, value| acc << value.to_i}
    
    [time, cpu, mem, swap]
  end
  
  private
  
  def vmstat
    @vmstate ||= `vmstat 1 2`.split(/\n/)
  end
  
  def free
    @free ||= `free -o -m`.split(/\n/)
  end
  
  def pop_old_stats
    @redis.lpop(@config.queues[:time])
    @redis.lpop(@config.queues[:cpu])
    @redis.lpop(@config.queues[:mem])
    @redis.lpop(@config.queues[:swap])
  end
end

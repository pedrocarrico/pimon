require 'redis'
require "#{File.dirname(__FILE__)}/queues"

class StatsChecker
  
  def initialize
    @redis = Redis.new(:path => '/tmp/redis.sock')
    @number_of_checks = 6
  end

  def check_stats
    vmstat = `vmstat 1 2`.split(/\n/)
    mem = `free -o -m`.split(/\n/)

    cpu_idle = vmstat[3].split(" ")[14].to_i

    ram = mem[1].split(" ")
    swap = mem[2].split(" ")

    mem_total  = ram[1].to_i
    mem_used   = ram[2].to_i
    swap_total = swap[1].to_i
    swap_used  = swap[2].to_i

    [ 100 - cpu_idle , ((mem_used.to_f / mem_total) * 100).to_i, ((swap_used.to_f / swap_total) * 100).to_i ]
  end

  def run
    fill_up_queue

    @redis.pipelined do
      @redis.lpop(Queues::TIME)
      @redis.lpop(Queues::CPU)
      @redis.lpop(Queues::MEM)
      @redis.lpop(Queues::SWAP)

      cpu_usage, mem_usage, swap_usage = check_stats

      @redis.rpush(Queues::TIME, Time.now.strftime("%Y-%m-%d %H:%M:%S"))
      @redis.rpush(Queues::CPU, cpu_usage)
      @redis.rpush(Queues::MEM, mem_usage)
      @redis.rpush(Queues::SWAP, swap_usage)
    end
  end

  private
  
  def fill_up_queue
    queue_size = @redis.llen(Queues::TIME)

    while queue_size < @number_of_checks
      @redis.pipelined do
        @redis.rpush(Queues::TIME, Time.now.strftime("%Y-%m-%d %H:%M:%S"))
        @redis.lpush(Queues::CPU,  0)
        @redis.lpush(Queues::MEM,  0)
        @redis.lpush(Queues::SWAP, 0)
      end
      queue_size += 1
    end
  end
end

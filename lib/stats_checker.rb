require 'redis'

class StatsChecker
  TIME_QUEUE = 'pimon_time'
  
  CPU_USR_QUEUE = 'pimon_cpu_usr'
  CPU_SYS_QUEUE = 'pimon_cpu_sys'
  CPU_IDL_QUEUE = 'pimon_cpu_idl'
  
  def initialize
    @redis = Redis.new(:path => '/tmp/redis.sock')
    @number_of_checks = 6
  end

  def check_cpu
    dstat_cpu = `dstat -c -C total --noupdate 1 1`.split(/\n/)
    # the second update of dstat is much more accurate
    usr, sys, idl = dstat_cpu[3].split(" ")
  end

  def run
    fill_up_cpu_queue

    @redis.pipelined do
      @redis.lpop(TIME_QUEUE)
      
      @redis.lpop(CPU_USR_QUEUE)
      @redis.lpop(CPU_SYS_QUEUE)
      @redis.lpop(CPU_IDL_QUEUE)
      
      usr, sys, idl = check_cpu

      @redis.rpush(TIME_QUEUE, Time.now.strftime("%H:%M:%S"))

      @redis.rpush(CPU_USR_QUEUE, usr)
      @redis.rpush(CPU_SYS_QUEUE, sys)
      @redis.rpush(CPU_IDL_QUEUE, idl)
    end
  end

  private
  
  def fill_up_cpu_queue
    queue_size = @redis.llen(TIME_QUEUE)

    while queue_size < @number_of_checks
      @redis.pipelined do
        @redis.rpush(TIME_QUEUE, Time.now.strftime("%H:%M:%S"))
        @redis.lpush(CPU_USR_QUEUE, 0)
        @redis.lpush(CPU_SYS_QUEUE, 0)
        @redis.lpush(CPU_IDL_QUEUE, 0)
      end
      queue_size += 1
    end
  end
end

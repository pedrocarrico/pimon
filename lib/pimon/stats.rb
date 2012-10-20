class Stats
  
  def initialize(queues)
    @stats = {}
    queues.each do |queue|
      @stats[queue] = []
    end
  end
  
  def index(queue, index)
    @stats[queue][index]
  end

  def push(queue, value)
    @stats[queue].push(value)
  end
  
  def shift(queue)
    @stats[queue].shift
  end
  
  def range(queue)
    @stats[queue]
  end
end

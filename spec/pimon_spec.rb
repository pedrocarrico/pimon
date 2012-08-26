require 'spec_helper'
require 'pry'

describe "Pimon" do
  
  context "when not authenticated" do
    
    it "should be not authorized" do
      get '/'
      last_response.status.should == 401
    end
  end
  
  context "when authenticated" do
    before { authorize 'pimon', 'pimon' }
    
    it "should be success" do
      fill_up_queues

      get '/'
      last_response.should be_ok
    end
  end
  
  private
  
  def fill_up_queues
    queue_size = Pimon.settings.redis.llen(Queues::TIME)
    @number_of_checks = 6
    while queue_size < @number_of_checks
      Pimon.settings.redis.rpush(Queues::TIME, Time.now.strftime("%Y-%m-%d %H:%M:%S"))
      Pimon.settings.redis.lpush(Queues::CPU,  0)
      Pimon.settings.redis.lpush(Queues::MEM,  0)
      Pimon.settings.redis.lpush(Queues::SWAP, 0)
      queue_size += 1
    end    
  end
end

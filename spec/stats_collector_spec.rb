require 'spec_helper'
require 'stats_collector_helper'

describe 'StatsCollector' do
  context 'when new with a valid config and redis' do
    before do
      @stats_collector = StatsCollector.new(PimonConfig.create_new('test'), MockRedis.new)
    end
    subject { @stats_collector }
    
    it 'should collect_stats' do
      @stats_collector.should_receive(:free).and_return(fake_free)
      @stats_collector.should_receive(:vmstat).and_return(fake_vmstat)
      
      @stats_collector.collect_stats
    end
    
    its(:show_stats) { should == { :cpu=> { :color => "#D2691E",
                                            :stats => [] },
                                   :disk=> { :color => "#CDC673",
                                             :stats => [] },
                                   :mem => { :color => "#87CEFA",
                                             :stats => [] },
                                   :swap => { :color => "#3CB371",
                                              :stats=> [] },
                                   :time => { :stats=>[] } ,
                                   :refresh_interval_in_millis=>600000 }
                     }
    
    context 'when collected some stats' do
      before do
        Timecop.freeze(Time.local(2012, 9, 1, 12, 0, 0))
        @stats_collector.should_receive(:free).any_number_of_times.and_return(fake_free)
        @stats_collector.should_receive(:vmstat).any_number_of_times.and_return(fake_vmstat)
        
        7.times do
          @stats_collector.collect_stats
        end
      end
      
      its(:show_stats) { should == { :cpu => { :color => "#D2691E",
                                               :stats => [50, 50, 50, 50, 50, 50] },
                                     :disk => { :color=> "#CDC673",
                                                :stats => [25, 25, 25, 25, 25, 25] },
                                     :mem => { :color=> "#87CEFA",
                                               :stats=>[78, 78, 78, 78, 78, 78] },
                                     :swap => { :color => "#3CB371",
                                                :stats => [50, 50, 50, 50, 50, 50] },
                                     :time => {:stats=>["12:00:00", "12:00:00", "12:00:00", "12:00:00", "12:00:00", "12:00:00"]},
                                     :refresh_interval_in_millis=>600000}
                       }
    end
  end
end

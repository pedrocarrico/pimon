# encoding: UTF-8

require 'spec_helper'
require 'json'

describe 'StatsCollector' do
  context 'when new with a valid config' do
    before do
      @stats_collector = StatsCollector.new(PimonConfig.create_new("#{File.dirname(__FILE__)}/../config/test.yml"))
    end
    subject { @stats_collector }
    
    it 'should collect_stats' do
      Probe::CpuUsage.should_receive(:check)
      Probe::DiskUsage.should_receive(:check)
      Probe::MemoryUsage.should_receive(:check)
      Probe::SwapUsage.should_receive(:check)
      Probe::Temperature.should_receive(:check)
      
      @stats_collector.collect_stats
    end
    
    its(:show_stats) { 
                        should == {
                          :time => { :stats => [] },
                          :hostname => 'test_hostname',
                          :cpu => { :stats => [], :color => '#D2691E', :unit => '%' },
                          :mem => { :stats => [], :color => '#87CEFA', :unit => '%' },
                          :swap => {:stats => [], :color => '#3CB371', :unit => '%' },
                          :disk => {:stats => [], :color => '#CDC673', :unit => '%' },
                          :temp => {:stats => [], :color => '#FF9B04', :unit => 'ºC' }
                        }.to_json
                     }
    
    context 'when collected some stats' do
      before do
        Timecop.freeze(Time.local(2012, 9, 1, 12, 0, 0))
        
        Probe::CpuUsage.should_receive(:check).any_number_of_times.and_return(50)
        Probe::DiskUsage.should_receive(:check).any_number_of_times.and_return(25)
        Probe::MemoryUsage.should_receive(:check).any_number_of_times.and_return(78)
        Probe::SwapUsage.should_receive(:check).any_number_of_times.and_return(50)
        Probe::Temperature.should_receive(:check).any_number_of_times.and_return(40)
        
        7.times do
          @stats_collector.collect_stats
        end
      end
      
      its(:show_stats) {
                          should == {
                            :time => { :stats => ['12:00:00', '12:00:00', '12:00:00', '12:00:00', '12:00:00', '12:00:00']},
                            :hostname => 'test_hostname',
                            :cpu => {:stats => [50, 50, 50, 50, 50, 50], :color => '#D2691E', :unit => '%'},
                            :mem => { :stats => [78, 78, 78, 78, 78, 78], :color =>'#87CEFA', :unit => '%'},
                            :swap=>{ :stats => [50, 50, 50, 50, 50, 50], :color => '#3CB371', :unit => '%'},
                            :disk=>{ :stats => [25, 25, 25, 25, 25, 25], :color => '#CDC673', :unit => '%'},
                            :temp=>{ :stats => [40, 40, 40, 40, 40, 40], :color => '#FF9B04', :unit => 'ºC'}
                          }.to_json
                       }
    end
  end
end

# encoding: UTF-8

require 'spec_helper'
require 'json'

describe 'StatsCollector' do
  context 'when new with a valid config' do
    let(:stats_collector) { StatsCollector.new(PimonConfig.create_new("#{File.dirname(__FILE__)}/../config/test.yml")) }
    
    it 'collects every stat' do
      stats_collector.probes.each { |probe| allow(probe).to receive(:check) }
      stats_collector.collect_stats
    end
    
    describe '#show_stats' do
      subject { stats_collector.show_stats }
      let(:expected_stats) do
        {
          :time => { :stats => [] },
          :hostname => 'test_hostname',
          :uptime => [],
          :cpu => { :stats => [], :color => '#D2691E', :unit => '%' },
          :mem => { :stats => [], :color => '#87CEFA', :unit => '%' },
          :swap => {:stats => [], :color => '#3CB371', :unit => '%' },
          :disk => {:stats => [], :color => '#CDC673', :unit => '%' },
          :temp => {:stats => [], :color => '#FF9B04', :unit => 'ºC' }
        }.to_json
      end
      it { is_expected.to eq(expected_stats) }
    end

    context 'when collected some stats' do
      before do
        Timecop.freeze(Time.local(2012, 9, 1, 12, 0, 0))
        
        allow(Probe::CpuUsage).to receive(:check).and_return(50)
        allow(Probe::DiskUsage).to receive(:check).and_return(25)
        allow(Probe::MemoryUsage).to receive(:check).and_return(78)
        allow(Probe::SwapUsage).to receive(:check).and_return(50)
        allow(Probe::Temperature).to receive(:check).and_return(40)
        allow(Probe::Uptime).to receive(:check).and_return([1,2,3,4])
        
        7.times do
          stats_collector.collect_stats
        end
      end
      
      describe '#show_stats' do
        subject { stats_collector.show_stats }
        let(:expected_stats) do
          {
            :time => { :stats => ['12:00:00', '12:00:00', '12:00:00', '12:00:00', '12:00:00', '12:00:00']},
            :hostname => 'test_hostname',
            :uptime => [[1,2,3,4],[1,2,3,4],[1,2,3,4],[1,2,3,4],[1,2,3,4],[1,2,3,4]],
            :cpu => {:stats => [50, 50, 50, 50, 50, 50], :color => '#D2691E', :unit => '%'},
            :mem => { :stats => [78, 78, 78, 78, 78, 78], :color =>'#87CEFA', :unit => '%'},
            :swap=>{ :stats => [50, 50, 50, 50, 50, 50], :color => '#3CB371', :unit => '%'},
            :disk=>{ :stats => [25, 25, 25, 25, 25, 25], :color => '#CDC673', :unit => '%'},
            :temp=>{ :stats => [40, 40, 40, 40, 40, 40], :color => '#FF9B04', :unit => 'ºC'}
          }.to_json
        end
        it { is_expected.to eq(expected_stats) }
      end
    end
  end
end

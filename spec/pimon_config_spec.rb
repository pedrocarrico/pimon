require 'spec_helper'

describe 'PimonConfig' do
  context 'when created for the test environment' do
    subject { PimonConfig.create_new("#{File.dirname(__FILE__)}/../config/test.yml") }
    
    its(:basic_auth) { should == ['pimon', 'pimon'] }
    its(:chart) { should == { :cpu => { :color => '#D2691E' }, :disk => { :color => '#CDC673' }, :mem => { :color => '#87CEFA' }, :temp => {:color=>"#FF9B04"}, :swap => { :color => '#3CB371' } } }
    its(:is_basic_auth_enabled?) { should be_true }
    its(:queues) { should == { :time => 'pimon_time', :cpu => 'pimon_cpu', :disk => 'pimon_disk', :mem => 'pimon_mem', :temp => 'pimon_temp', :swap => 'pimon_swap' } }
    its(:redis) { should == { :socket  => '/thou/shalt/not/use/redis/on/test/environment' } }
    its(:stats) { should == { :number_of_stats => 6, :time_period_in_min => 10 } }
    its(:valid?) { should be_true }
  end
  
  context 'when created with an invalid environment' do
    it 'should raise an error' do
      expect{ PimonConfig.create_new('invalid') }.to raise_error(Errno::ENOENT)
    end
  end
  
  context 'when created with a broken environment configuration with basic_auth enabled but no username/password' do
    it 'should raise an error' do
      expect{ PimonConfig.create_new("#{File.dirname(__FILE__)}/../config/test_broken.yml") }.to raise_error(RuntimeError)
    end
  end
end

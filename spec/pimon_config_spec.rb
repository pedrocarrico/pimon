require 'spec_helper'

describe 'PimonConfig' do
  context 'when created with no arguments' do
    subject { PimonConfig.create_new }
    
    its(:environment) { should == 'development' }
  end
  
  context 'when created for the test environment' do
    subject { PimonConfig.create_new('test') }
    
    its(:basic_auth) { should == ['pimon', 'pimon'] }
    its(:chart) { should == { :cpu => { :color => '#D2691E' }, :mem => { :color => '#87CEFA' }, :swap => { :color => '#3CB371' } } }
    its(:is_basic_auth_enabled?) { should be_true }
    its(:environment) { should == 'test' }
    its(:queues) { should == { :time => 'pimon_time', :cpu => 'pimon_cpu', :mem => 'pimon_mem', :swap => 'pimon_swap' } }
    its(:redis) { should == { :socket  => '/thou/shalt/not/use/redis/on/test/environment' } }
    its(:stats) { should == { :daemonize => false, :pid_dir => 'pids', :log_dir => 'log', :number_of_stats => 6, :time_period_in_min => 10 } }
    its(:valid?) { should be_true }
  end
  
  context 'when created with an invalid environment' do
    it 'should raise an error' do
      expect{ PimonConfig.create_new('invalid') }.to raise_error(Errno::ENOENT)
    end
  end
  
  context 'when created with a broken environment configuration with basic_auth enabled but no username/password' do
    it 'should raise an error' do
      expect{ PimonConfig.create_new('test_broken') }.to raise_error(RuntimeError)
    end
  end
end

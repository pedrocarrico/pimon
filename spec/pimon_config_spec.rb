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
    its(:stats) { should == { :slices => 6, :time_period_in_min => 10 } }
    its(:valid?) { should be_true }
  end
end
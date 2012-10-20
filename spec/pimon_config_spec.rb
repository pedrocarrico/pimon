require 'spec_helper'

describe 'PimonConfig' do
  context 'when created for the test environment' do
    subject { PimonConfig.create_new("#{File.dirname(__FILE__)}/../config/test.yml") }
    
    its(:chart) { should == { :cpu => { :color => '#D2691E' }, :disk => { :color => '#CDC673' }, :mem => { :color => '#87CEFA' }, :temp => {:color=>"#FF9B04"}, :swap => { :color => '#3CB371' } } }
    its(:stats) { should == { :number_of_stats => 6, :time_period_in_min => 10 } }
  end
  
  context 'when created with an invalid environment' do
    it 'should raise an error' do
      expect{ PimonConfig.create_new('invalid') }.to raise_error(Errno::ENOENT)
    end
  end
end

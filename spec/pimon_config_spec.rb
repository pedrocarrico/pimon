require 'spec_helper'

describe 'PimonConfig' do
  context 'when created for the test environment' do
    let(:config) { PimonConfig.create_new("#{File.dirname(__FILE__)}/../config/test.yml") }

    describe '#chart' do
      subject { config.chart }

      it { is_expected.to eq({ :cpu => { :color => '#D2691E' }, :disk => { :color => '#CDC673' }, :mem => { :color => '#87CEFA' }, :temp => {:color=>"#FF9B04"}, :swap => { :color => '#3CB371' } }) }
    end

    describe '#stats' do
      subject { config.stats }
      it { is_expected.to eq({ :number_of_stats => 6, :time_period_in_min => 10 }) }
    end

    describe '#hostname' do
      subject { config.hostname }
      it { is_expected.to eq('test_hostname') }
    end

  end

  context 'when created with an invalid environment' do
    it 'raises an error' do
      expect{ PimonConfig.create_new('invalid') }.to raise_error(Errno::ENOENT)
    end
  end
end

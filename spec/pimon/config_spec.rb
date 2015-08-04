require 'spec_helper'

describe Pimon::Config do
  context 'when created for the test environment' do
    let(:config) { described_class.load(Pimon::Test::CONFIG) }

    describe '#colors' do
      subject { config.colors }

      let(:expected_result) do
        { 'cpu' => '#D2691E', 'disk' => '#CDC673', 'mem' => '#87CEFA', 'temp' => '#FF9B04', 'swap' => '#3CB371' }
      end

      it { is_expected.to eq(expected_result) }
    end

    describe '#stats' do
      subject { config.stats }
      it { is_expected.to eq('time_period_in_min' => 10) }
    end

    describe '#hostname' do
      subject { config.hostname }
      it { is_expected.to eq('test_hostname') }
    end
  end

  context 'when created with an invalid environment' do
    it 'raises an error' do
      expect { Pimon::Config.load('invalid') }.to raise_error(Errno::ENOENT)
    end
  end
end

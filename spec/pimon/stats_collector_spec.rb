require 'spec_helper'
require 'json'

describe Pimon::StatsCollector do
  context 'when new with a valid config' do
    let(:stats_collector) { described_class.new(Pimon::Config.load(Pimon::Test::CONFIG)) }

    it 'collects every stat' do
      stats_collector.probes.each { |probe| allow(probe).to receive(:check) }
      stats_collector.collect_stats
    end
  end
end

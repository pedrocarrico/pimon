require 'date'
require 'json'

require 'pimon/probe'

module Pimon
  class StatsCollector
    attr_accessor :config
    attr_accessor :last_update
    attr_accessor :probes
    attr_accessor :probe_threads
    attr_reader :stats

    CHART_PROBES = [
      Pimon::Probe::CpuUsage,
      Pimon::Probe::MemoryUsage,
      Pimon::Probe::SwapUsage,
      Pimon::Probe::DiskUsage,
      Pimon::Probe::Temperature
    ]

    SINGLE_PROBES = [
      Pimon::Probe::Uptime,
      Pimon::Probe::CpuFreq
    ]

    def initialize(config)
      @config = config
      @probes = {
        charts: CHART_PROBES,
        single: SINGLE_PROBES
      }
      @stats = { colors: config.colors, charts: {}, single: {}, hostname: config.hostname }
      @probe_threads = []
      @collection_mutex = Mutex.new
    end

    def collect_stats
      @collection_mutex.synchronize do
        self.last_update = Time.now

        [:charts, :single].each do |stats_type|
          probes[stats_type].each do |probe|
            self.probe_threads = []
            probe_threads << Thread.new do
              sample = probe.check(last_update)
              stats[stats_type][sample.probe_name] = sample
            end
          end
        end
      end
    end

    def show_stats
      wait_for_stats_collection { stats }
    end

    def charts
      wait_for_stats_collection { stats[:charts].keys }
    end

    def single_stats
      wait_for_stats_collection { stats[:single].keys }
    end

    private

    def wait_for_stats_collection
      @collection_mutex.synchronize do
        probe_threads.each(&:join)
        yield if block_given?
      end
    end
  end
end

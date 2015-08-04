require 'yaml'

module Pimon
  class Config
    attr_reader :config
    attr_reader :hostname

    def self.load(filename)
      new(filename)
    end

    def colors
      config['colors']
    end

    def stats
      config['stats_collector']
    end

    def hostname
      @hostname ||= config['hostname'].nil? ? `hostname` : config['hostname']
    end

    private

    def initialize(filename)
      @config = YAML.load_file(filename)
      @config.freeze
    rescue StandardError => e
      puts "Error while loading config file: #{filename}"
      raise e
    end
  end
end

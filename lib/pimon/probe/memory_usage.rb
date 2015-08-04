module Pimon
  module Probe
    class MemoryUsage
      def self.check(date = Time.now)
        options = {
          date: date.strftime('%Y-%m-%d %H:%M:%S'), probe_name: 'mem',
          value: SystemMemory.check(:mem),
          unit: unit
        }
        OpenStruct.new(options)
      end

      def self.unit
        '%'
      end
    end
  end
end

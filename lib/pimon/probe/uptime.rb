require 'sys/uptime'

module Pimon
  module Probe
    class Uptime
      def self.check(date = Time.now)
        OpenStruct.new(date: date.strftime('%Y-%m-%d %H:%M:%S'), probe_name: 'uptime', value: formatted_uptime)
      end

      def self.formatted_uptime
        days, hours, minutes, seconds = Sys::Uptime.dhms.map(&:to_i)

        uptime = ''
        { day: days, hour: hours, minute: minutes, second: seconds }.each do |time_unit, value|
          next if value == 0
          case time_unit
          when :day
            uptime = "#{days}#{pluralize(value, time_unit)}"
          when :second
            uptime = "#{insert_word_connector(uptime, ' and ')}#{value}#{pluralize(value, time_unit)}"
          when :hour, :minute
            uptime = "#{insert_word_connector(uptime, ', ')}#{value}#{pluralize(value, time_unit)}"
          end
        end
        uptime
      end

      def self.pluralize(count, word)
        " #{word}#{count == 1 ? '' : 's'}"
      end

      def self.insert_word_connector(text, connector)
        "#{text}#{text == '' ? '' : connector}"
      end

      def self.unit
        nil
      end
    end
  end
end

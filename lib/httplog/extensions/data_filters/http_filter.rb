require "httplog/extensions/data_filters/base_filter"

module Extensions
  module DataFilters
    class HttpFilter < BaseFilter

      def filter(data)
        return data if filtered_keys.nil? || filtered_keys.empty?
        data = split(data)
        data = raw_filter(data)
        join(data)
      end

      def suitable?(data)
        return if data.nil?
        data.strip[0] != "{" &&
          data.count("=") - data.count("&") == 1
      end

      private

      def split(data)
        data.split("&").map { |i| i.split("=", -1) }
      end

      def join(data)
        data.map { |i| i.join("=") }.join("&")
      end

      def raw_filter(data)
        filtered_keys.each do |filtered_key|
          data = filter_one(data, filtered_key)
        end
        data
      end

      def filter_one(data, filtered_key)
        data.map do |p|
          if p.first.match(/#{filtered_key}/i)
            [p.first, filtered_value]
          else
            p
          end
        end
      end

    end
  end
end

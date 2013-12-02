require "json"
require "httplog/extensions/data_filters/base_filter"

module Extensions
  module DataFilters
    class JsonFilter < BaseFilter

      def filter(data)
        return data if filtered_keys.nil? || filtered_keys.empty?

        data = JSON.parse(data)
        data = raw_filter(data)
        data.to_json
      end

      def suitable?(data)
        return if data.nil?
        data.match(/\{.*\}/)
      end

      private

      def raw_filter(hash)
        filtered_keys.each do |filtered_key|
          hash.each do |k, v|
            if k.match(/#{filtered_key}/i)
              hash[k] = filtered_value
            end
          end
        end
        hash
      end

    end
  end
end

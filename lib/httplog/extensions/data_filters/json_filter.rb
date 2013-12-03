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
        data.match(/\A\[?\{.*\}\]?\z/)
      end

      private

      def raw_filter(json)
        filtered_keys.each do |filtered_key|
          json = filter_one(json, filtered_key)
        end
        json
      end

      def filter_one(json, filtered_key)
        if json.is_a?(Array) # TODO refactor this
          json.each_index do |index|
            json[index] = filter_one(json[index], filtered_key)
          end
        else
          json.each do |k, v|
            if k.match(/#{filtered_key}/i)
              json[k] = @replacer.replace(v)
            elsif v.is_a?(Hash) || v.is_a?(Array)
              json[k] = filter_one(v, filtered_key)
            end
          end
        end
      end

    end
  end
end

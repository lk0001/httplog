require "json"
require "httplog/extensions/data_filters/base_filter"

module Extensions
  module DataFilters
    class EmptyFilter < BaseFilter

      def filter(data)
        data
      end

      def suitable?(data)
        true
      end

    end
  end
end

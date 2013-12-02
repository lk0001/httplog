require "httplog/extensions/data_filters/http_filter"
require "httplog/extensions/data_filters/json_filter"
require "httplog/extensions/data_filters/base_filter"

module Extensions
  module DataFilters
    class Factory

      FILTERED_VALUE = BaseFilter::FILTERED_VALUE

      def initialize(opts={})
        @filters = []
        filter_classes.each do |fc|
          @filters << fc.new(opts)
        end
      end

      def filter(data)
        filter_object(data).filter(data)
      end

      private

      def filter_object(data)
        detect_filter(data) || default_filter
      end

      def detect_filter(data)
        @filters.each do |filter|
          return filter if filter.suitable?(data)
        end
      end

      def filter_classes
        [HttpFilter, JsonFilter]
      end

      def default_filter
        @default_filter ||= EmptyFilter.new
      end

    end
  end
end

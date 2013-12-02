module Extensions
  module DataFilters
    class BaseFilter

      FILTERED_VALUE = "[FILTERED]".freeze

      attr_accessor :filtered_keys, :filtered_value

      def initialize(opts={})
        self.filtered_keys  = opts.fetch(:filtered_keys, [])
        self.filtered_value = opts.fetch(:filtered_value, FILTERED_VALUE)
      end

      def filter(data)
        raise "override this method in subclass"
      end

      def suitable?(data)
        raise "override this method in subclass"
      end

    end
  end
end

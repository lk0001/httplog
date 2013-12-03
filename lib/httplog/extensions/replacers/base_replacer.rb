module Extensions
  module Replacers
    class BaseReplacer

      attr_accessor :filtered_value

      def initialize(opts={})
        @filtered_value = opts.fetch(:filtered_value, default_filtered_value)
      end

      def replace(value)
        raise "override this method in subclass"
      end

      private

      def default_filtered_value
        "[FILTERED]"
      end

    end
  end
end

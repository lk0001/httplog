require "httplog/extensions/replacers/base_replacer"

module Extensions
  module Replacers
    class FullReplacer < BaseReplacer

      def replace(value)
        filtered_value
      end

      private

      def default_filtered_value
        "[FILTERED]"
      end

    end
  end
end

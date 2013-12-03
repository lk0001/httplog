require "httplog/extensions/replacers/base_replacer"

module Extensions
  module Replacers
    class HalfReplacer < BaseReplacer

      def replace(value)
        value = value.to_s
        fch = filtered_characters(value)
        filtered_value * fch + value.to_s.slice(fch...value.length)
      end

      private

      def visible_characters(value)
        value.length / 2
      end

      def filtered_characters(value)
        value.length - visible_characters(value)
      end

      def default_filtered_value
        "*"
      end

    end
  end
end

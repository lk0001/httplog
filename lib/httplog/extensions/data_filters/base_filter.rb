require "httplog/extensions/replacers/full_replacer"

module Extensions
  module DataFilters
    class BaseFilter

      attr_accessor :filtered_keys

      def initialize(opts={})
        @filtered_keys  = opts.fetch(:filtered_keys, [])
        @replacer       = opts.fetch(:replacer, default_replacer).new(opts)
      end

      def filter(data)
        raise "override this method in subclass"
      end

      def suitable?(data)
        raise "override this method in subclass"
      end

      private

      def default_replacer
        Extensions::Replacers::FullReplacer
      end

    end
  end
end

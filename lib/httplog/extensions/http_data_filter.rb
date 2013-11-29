module Extensions
  class HttpDataFilter

    FILTERED_VALUE = "[FILTERED]".freeze

    attr_accessor :filtered_keys, :filtered_value

    def initialize(opts={})
      self.filtered_keys  = opts.fetch(:filtered_keys)
      self.filtered_value = opts.fetch(:filtered_value, FILTERED_VALUE)
    end

    def filter(data)
      return "" if filtered_keys.nil? || filtered_keys.empty?
      data = split(data)
      data = raw_filter(data)
      join(data)
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

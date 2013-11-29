require "net/http"
require "logger"
require "benchmark"
require "httplog/extensions/http_data_filter"

module HttpLog
  DEFAULT_LOGGER  = Logger.new($stdout)
  DEFAULT_FILTER  = Extensions::HttpDataFilter
  DEFAULT_OPTIONS = {
    :logger                => DEFAULT_LOGGER,
    :severity              => Logger::Severity::DEBUG,
    :log_connect           => true,
    :log_request           => true,
    :log_headers           => false,
    :log_data              => true,
    :log_status            => true,
    :log_response          => true,
    :log_benchmark         => true,
    :compact_log           => false,
    :url_whitelist_pattern => /.*/,
    :url_blacklist_pattern => nil,
    :truncate              => false,
    :max_length            => 1024,
    :filter_data           => false,
    :filter_class          => DEFAULT_FILTER,
    :filtered_keys         => [],
    :filtered_value        => DEFAULT_FILTER::FILTERED_VALUE,
  }

  LOG_PREFIX       = "[httplog] ".freeze
  TRUNCATED_SUFFIX = " (truncated)".freeze

  class << self
    def options
      @@options ||= DEFAULT_OPTIONS.clone
    end

    def reset_options!
      @@options = DEFAULT_OPTIONS.clone
    end

    def filter_object
      options[:filter_object] ||= options[:filter_class].new(
                                    filtered_keys: options[:filtered_keys],
                                    filtered_value: options[:filtered_value]
                                  )
    end

    def url_approved?(url)
      unless @@options[:url_blacklist_pattern].nil?
        return false if url.to_s.match(@@options[:url_blacklist_pattern])
      end

      url.to_s.match(@@options[:url_whitelist_pattern])
    end

    def log(msg)
      @@options[:logger].add(@@options[:severity]) do
        LOG_PREFIX + formatted_message(msg)
      end
    end

    def log_connection(host, port = nil)
      return if options[:compact_log] || !options[:log_connect]
      log("Connecting: #{[host, port].compact.join(":")}")
    end

    def log_request(method, uri)
      return if options[:compact_log] || !options[:log_request]
      log("Sending: #{method.to_s.upcase} #{uri}")
    end

    def log_headers(headers = {})
      return if options[:compact_log] || !options[:log_headers]
      headers.each do |key,value|
        log("Header: #{key}: #{value}")
      end
    end

    def log_status(status)
      return if options[:compact_log] || !options[:log_status]
      log("Status: #{status}")
    end

    def log_benchmark(seconds)
      return if options[:compact_log] || !options[:log_benchmark]
      log("Benchmark: #{seconds} seconds")
    end

    def log_body(body, encoding = nil)
      return if options[:compact_log] || !options[:log_response]
      if body.is_a?(Net::ReadAdapter)
        # open-uri wraps the response in a Net::ReadAdapter that defers reading
        # the content, so the reponse body is not available here.
        log("Response: (not available yet)")
      else
        if encoding =~ /gzip/
          sio = StringIO.new( body.to_s )
          gz = Zlib::GzipReader.new( sio )
          log("Response: (deflated)\n#{gz.read}")
        else
          log("Response:\n#{body.to_s}")
        end
      end
    end

    def log_data(data)
      return if options[:compact_log] || !options[:log_data]
      data = filter_object.filter(data) if options[:filter_data]
      log("Data: #{data}")
    end

    def log_compact(method, uri, status, seconds)
      return unless options[:compact_log]
      status = Rack::Utils.status_code(status) unless status == /\d{3}/
      log("#{method.to_s.upcase} #{uri} completed with status code #{status} in #{seconds} seconds")
    end

    def formatted_message(msg) # TODO refactor
      if options[:truncate] && msg.length > options[:max_length]
        truncate(msg, options[:max_length])
      else
        msg
      end
    end

    def truncate(msg, length)
      msg[0...length] + TRUNCATED_SUFFIX
    end
  end
end

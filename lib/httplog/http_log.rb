require "net/http"
require "logger"
require "benchmark"
require "httplog/extensions/data_filters/factory"
require "httplog/extensions/replacers/full_replacer"
require "httplog/extensions/replacers/half_replacer"

module HttpLog
  DEFAULT_LOGGER          = Logger.new($stdout)
  DEFAULT_FILTER          = Extensions::DataFilters::Factory
  DEFAULT_REPLACER        = Extensions::Replacers::FullReplacer
  DEFAULT_CUSTOM_FILTER   = Extensions::DataFilters::Factory
  DEFAULT_CUSTOM_REPLACER = Extensions::Replacers::HalfReplacer
  DEFAULT_OPTIONS = {
    :logger                 => DEFAULT_LOGGER,
    :severity               => Logger::Severity::DEBUG,
    :log_connect            => true,
    :log_request            => true,
    :log_headers            => false,
    :log_data               => true,
    :log_status             => true,
    :log_response           => true,
    :log_benchmark          => true,
    :compact_log            => false,
    :url_whitelist_pattern  => /.*/,
    :url_blacklist_pattern  => nil,
    :truncate               => false,
    :max_length             => 1024,
    :filter_data            => false,
    :filter_class           => DEFAULT_FILTER,
    :filter_replacer        => DEFAULT_REPLACER,
    :filtered_keys          => [],
    :filtered_value         => DEFAULT_FILTER::FILTERED_VALUE,
    :filter_custom_data     => false,
    :filter_custom_response => false,
    :custom_filter_class    => DEFAULT_CUSTOM_FILTER,
    :custom_filter_replacer => DEFAULT_CUSTOM_REPLACER,
    :custom_filtered_keys   => [],
    :custom_filtered_value  => DEFAULT_CUSTOM_FILTER::FILTERED_VALUE, # change to replacer::defvalue
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
        replacer: options[:filter_replacer],
        filtered_keys: options[:filtered_keys],
        filtered_value: options[:filtered_value],
      )
    end

    def custom_filter_object
      options[:custom_filter_object] ||= options[:custom_filter_class].new(
        replacer: options[:custom_filter_replacer],
        filtered_keys: options[:custom_filtered_keys],
        filtered_value: options[:custom_filtered_value],
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
          data = potentially_apply_filter(gz.read, custom_filter_object, options[:filter_custom_response])
          log("Response: (deflated)\n#{data}")
        else
          data = potentially_apply_filter(body.to_s, custom_filter_object, options[:filter_custom_response])
          log("Response:\n#{data}")
        end
      end
    end

    def log_data(data)
      return if options[:compact_log] || !options[:log_data]
      data = potentially_apply_filter(data, filter_object, options[:filter_data])
      data = potentially_apply_filter(data, custom_filter_object, options[:filter_custom_data])
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

    def potentially_apply_filter(data, filter_object, apply) # TODO refactor
      if apply
        filter_object.filter(data)
      else
        data
      end
    end
  end
end

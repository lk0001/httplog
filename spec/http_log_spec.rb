require 'spec_helper'

describe HttpLog do

  before do
    @host = 'localhost'
    @port = 9292
    @path = "/index.html"
    @data = "foo=bar&bar=foo"
  end

  ADAPTERS = [
    NetHTTPAdapter,
    OpenUriAdapter,
    HTTPClientAdapter,
    HTTPartyAdapter,
    FaradayAdapter,
    ExconAdapter,
    EthonAdapter,
    TyphoeusAdapter,
    PatronAdapter
  ]

  ADAPTERS.each do |adapter_class|
    context adapter_class do
      let(:adapter) { adapter_class.new(@host, @port, @path) }

      context "with default options" do
        connection_test_method = adapter_class.is_libcurl? ? :should_not : :should
        headers_test_method = adapter_class.should_log_headers? ? :should : :should_not

        if adapter_class.method_defined? :send_get_request
          it "should log GET requests" do
            res = adapter.send_get_request

            log.send(connection_test_method, include(HttpLog::LOG_PREFIX + "Connecting: #{@host}:#{@port}"))

            log.should include(HttpLog::LOG_PREFIX + "Sending: GET http://#{@host}:#{@port}#{@path}")
            log.should_not include(HttpLog::LOG_PREFIX + "Data:")
            log.should_not include(HttpLog::LOG_PREFIX + "Header:")
            log.should include(HttpLog::LOG_PREFIX + "Status: 200")
            log.should include(HttpLog::LOG_PREFIX + "Benchmark: ")
            log.should include(HttpLog::LOG_PREFIX + "Response:#{adapter.expected_response_body}")
            log.should_not include(HttpLog::TRUNCATED_SUFFIX)

            res.should be_a adapter.response_should_be if adapter.respond_to? :response_should_be
          end
        end

        if adapter_class.method_defined? :send_post_request
          it "should log POST requests" do
            res = adapter.send_post_request

            log.send(connection_test_method, include(HttpLog::LOG_PREFIX + "Connecting: #{@host}:#{@port}"))

            log.should include(HttpLog::LOG_PREFIX + "Sending: POST http://#{@host}:#{@port}#{@path}")
            log.should include(HttpLog::LOG_PREFIX + "Data: #{@data}")
            log.should_not include(HttpLog::LOG_PREFIX + "Header:")
            log.should include(HttpLog::LOG_PREFIX + "Status: 200")
            log.should include(HttpLog::LOG_PREFIX + "Benchmark: ")
            log.should include(HttpLog::LOG_PREFIX + "Response:#{adapter.expected_response_body}")
            log.should_not include(HttpLog::TRUNCATED_SUFFIX)

            res.should be_a adapter.response_should_be if adapter.respond_to? :response_should_be
          end
        end
      end

      context "with custom config" do
        truncate_test_method = adapter_class.possible_to_truncate? ? :should : :should_not

        it "should log at other levels" do
          HttpLog.options[:severity] = Logger::Severity::INFO
          adapter.send_get_request
          log.should include("INFO")
        end

        it "should log headers if enabled" do
          HttpLog.options[:log_headers] = true
          adapter.send_get_request
          log.should include(HttpLog::LOG_PREFIX + "Header: accept: */*")
        end

        it "should not log headers if disabled" do
          HttpLog.options[:log_headers] = false
          adapter.send_get_request
          log.should_not include(HttpLog::LOG_PREFIX + "Header:")
        end

        it "should log the request if url does not match blacklist pattern" do
          HttpLog.options[:url_blacklist_pattern] = /example.com/
          adapter.send_get_request
          log.should include(HttpLog::LOG_PREFIX + "Sending: GET")
        end

        it "should log the request if url matches whitelist pattern and not the blacklist pattern" do
          HttpLog.options[:url_blacklist_pattern] = /example.com/
          HttpLog.options[:url_whitelist_pattern] = /#{@host}:#{@port}/
          adapter.send_get_request
          log.should include(HttpLog::LOG_PREFIX + "Sending: GET")
        end

        it "should not log the request if url matches blacklist pattern" do
          HttpLog.options[:url_blacklist_pattern] = /#{@host}:#{@port}/
          adapter.send_get_request
          log.should_not include(HttpLog::LOG_PREFIX + "Sending: GET")
        end

        it "should not log the request if url does not match whitelist pattern" do
          HttpLog.options[:url_whitelist_pattern] = /example.com/
          adapter.send_get_request
          log.should_not include(HttpLog::LOG_PREFIX + "Sending: GET")
        end

        it "should not log the request if url matches blacklist pattern and the whitelist pattern" do
          HttpLog.options[:url_blacklist_pattern] = /#{@host}:#{@port}/
          HttpLog.options[:url_whitelist_pattern] = /#{@host}:#{@port}/
          adapter.send_get_request
          log.should_not include(HttpLog::LOG_PREFIX + "Sending: GET")
        end

        it "should not log the request if disabled" do
          HttpLog.options[:log_request] = false
          adapter.send_get_request
          log.should_not include(HttpLog::LOG_PREFIX + "Sending: GET")
        end

        it "should not log the connection if disabled" do
          HttpLog.options[:log_connect] = false
          adapter.send_get_request
          log.should_not include(HttpLog::LOG_PREFIX + "Connecting: #{@host}:#{@port}")
        end

        it "should truncate the log if enabled" do
          HttpLog.options[:truncate]   = true
          HttpLog.options[:max_length] = 100
          adapter.send_get_request
          log.send(truncate_test_method, include(HttpLog::TRUNCATED_SUFFIX))
        end

        it "should not truncate the log if enabled but response is short enough" do
          HttpLog.options[:truncate]   = true
          HttpLog.options[:max_length] = 1000
          adapter.send_get_request
          log.should_not include(HttpLog::TRUNCATED_SUFFIX)
        end

        if adapter_class.method_defined? :send_post_request
          it "should not log POST data if disabled" do
            HttpLog.options[:log_data] = false
            adapter.send_post_request
            log.should_not include(HttpLog::LOG_PREFIX + "Data:")
          end

          it "should not log the response if disabled" do
            HttpLog.options[:log_response] = false
            adapter.send_post_request
            log.should_not include(HttpLog::LOG_PREFIX + "Reponse:")
          end

          it "should not log the benchmark if disabled" do
            HttpLog.options[:log_benchmark] = false
            adapter.send_post_request
            log.should_not include(HttpLog::LOG_PREFIX + "Benchmark:")
          end

          it "should truncate the log if enabled and response is too long" do
            HttpLog.options[:truncate]   = true
            HttpLog.options[:max_length] = 100
            adapter.send_post_request
            log.send(truncate_test_method, include(HttpLog::TRUNCATED_SUFFIX))
          end

          it "should not truncate the log if enabled but response is short enough" do
            HttpLog.options[:truncate]   = true
            HttpLog.options[:max_length] = 1000
            adapter.send_post_request
            log.should_not include(HttpLog::TRUNCATED_SUFFIX)
          end

          describe "with data filtering enabled" do
            before(:each) do
              HttpLog.options[:filter_data]    = true
              HttpLog.options[:filtered_keys]  = [:foo]
              HttpLog.options[:filtered_value] = "[FV]"
            end

            it "should filter http data" do
              adapter.send_post_request
              log.should include("foo=[FV]")
            end

            it "should filter json data" do
              adapter.send_json_post_request
              log.should include('"foo":"[FV]"')
            end
          end

          describe "with custom data filtering enabled" do
            before(:each) do
              HttpLog.options[:filter_custom_data]    = true
              HttpLog.options[:custom_filtered_keys]  = [:foo]
              HttpLog.options[:custom_filtered_value] = "*"
            end

            it "should filter http data" do
              adapter.send_post_request
              log.should include("foo=**r")
            end

            it "should filter json data" do
              adapter.send_json_post_request
              log.should include('"foo":"**r"')
            end
          end
        end
      end

      context "with compact config" do
        it "should log a single line with status and benchmark" do
          HttpLog.options[:compact_log] = true
          adapter.send_get_request

          log.should match /\[httplog\] GET http:\/\/#{@host}:#{@port}#{@path}(\?.*)? completed with status code \d{3} in (\d|\.)+/
          log.should_not include(HttpLog::LOG_PREFIX + "Connecting: #{@host}:#{@port}")
          log.should_not include(HttpLog::LOG_PREFIX + "Response:")
          log.should_not include(HttpLog::LOG_PREFIX + "Data:")
          log.should_not include(HttpLog::LOG_PREFIX + "Benchmark: ")
        end
      end
    end
  end
end

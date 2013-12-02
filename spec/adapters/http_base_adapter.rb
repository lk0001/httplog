class HTTPBaseAdapter
  def initialize(host, port, path, protocol = 'http')
    @host = host
    @port = port
    @path = path
    @protocol = protocol
    @headers = { "accept" => "*/*", "foo" => "bar" }
    @data = "foo=bar&bar=foo"
    @json_data = {foo: "bar", bar: "foo"}.to_json
    @params = {'foo' => 'bar', 'bar' => 'foo'}
  end

  def parse_uri
    URI.parse("#{@protocol}://#{@host}:#{@port}#{@path}")
  end

  def send_post_form_request
  end

  def send_json_post_request
    send_post_request(@json_data)
  end

  def expected_response_body
    "\n<html>"
  end

  def self.possible_to_truncate?
    true
  end

  def self.is_libcurl?
    false
  end

  def self.should_log_headers?
    true
  end
end

require 'excon'
class TyphoeusAdapter < HTTPBaseAdapter

  def send_get_request
    Typhoeus.get(parse_uri.to_s, headers: @headers)
  end

  def send_post_request(body=@data)
    Typhoeus.post(parse_uri.to_s, body: body, headers: @headers)
  end

  def self.is_libcurl?
    true
  end
end

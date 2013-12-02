require 'httparty'
class HTTPartyAdapter < HTTPBaseAdapter
  def send_get_request
    HTTParty.get(parse_uri.to_s, headers: @headers)
  end

  def send_post_request(body=@data)
    HTTParty.post(parse_uri.to_s, body: body, headers: @headers)
  end
end

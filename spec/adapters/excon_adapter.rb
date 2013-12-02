require 'excon'
class ExconAdapter < HTTPBaseAdapter
  def send_get_request
    Excon.get(parse_uri.to_s, headers: @headers )
  end

  def send_post_request(body=@data)
    Excon.post(parse_uri.to_s, body: body, headers: @headers)
  end
end

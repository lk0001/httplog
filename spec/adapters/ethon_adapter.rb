require "ethon"
class EthonAdapter < HTTPBaseAdapter
  def send_get_request
    easy = Ethon::Easy.new
    easy.http_request(parse_uri.to_s, :get, { headers: @headers })
    easy.perform
  end

  def send_post_request(body=@data)
    easy = Ethon::Easy.new
    easy.http_request(parse_uri.to_s, :post, { headers: @headers, body: body })
    easy.perform
  end

  def self.is_libcurl?
    true
  end
end

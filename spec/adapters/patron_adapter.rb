require "patron"
class PatronAdapter < HTTPBaseAdapter
  def send_get_request
    session = Patron::Session.new
    session.get(parse_uri.to_s, @headers)
  end

  def send_post_request(body=@data)
    session = Patron::Session.new
    session.post(parse_uri.to_s, body, @headers)
  end

  def self.is_libcurl?
    true
  end
end

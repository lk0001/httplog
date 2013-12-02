class NetHTTPAdapter < HTTPBaseAdapter
  def send_get_request
    Net::HTTP.get_response(@host, "#{@path}?#{@data}", @port)
  end

  def send_post_request(body=@data)
    http = Net::HTTP.new(@host, @port)
    resp = http.post(@path, body)
  end

  def send_post_form_request
    res = Net::HTTP.post_form(parse_uri, @params)
  end
end

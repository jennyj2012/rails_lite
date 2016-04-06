class Session

  attr_reader :cookie, :cookie_name

  def initialize(req)
    @cookie_name = "_test_cookie"
    raw_cookie = req.cookies[@cookie_name]

    if raw_cookie
      @cookie = JSON.parse(raw_cookie)
    else
      @cookie = {}
    end
  end

  def [](key)
    cookie[key]
  end

  def []=(key, value)
    @cookie[key] = value;
  end

  def store_session(response)
    json_cookie = cookie.to_json
    response.set_cookie(cookie_name, json_cookie) 
  end
end

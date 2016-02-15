require 'rack'
require '../lib/controller_base'
require '../lib/session'

class TestController < ControllerBase
  def start
    session["count"] ||= 0
    session["count"] += 1
    if @req.path == "/session"
      render_content("count: " + session["count"].to_s, 'text/html')
    else
      redirect_to("/session")
    end
  end

end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  TestController.new(req, res).start
  res.finish
end

Rack::Server.start(
  app: app,
  Port: 3000
)

require 'rack'
require '../lib/controller_base'

class TestController < ControllerBase
  def start
    if @req.path == "/test"
      render("test")
    else
      redirect_to("/test")
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

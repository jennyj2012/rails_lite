require 'rack'
require_relative '../lib/controller_base'
require_relative '../lib/session'
require_relative '../lib/router'

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  res['Content-Type'] = 'text/html'
  res.write("Welcome to Rails Lite")
  res.finish
end

class TestsController < ControllerBase
  def start
    if @req.path == "/test"
      render_content("Test Successful", 'text/html')
    else
      redirect_to("/test")
    end
  end

end

app2 = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  TestsControllers.new(req, res).start
  res.finish
end


class TemplatesController < ControllerBase
  def start
    if @req.path == "/template"
      render("template")
    else
      redirect_to("/template")
    end
  end

end

app3 = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  TemplatesController.new(req, res).start
  res.finish
end

class SessionsController < ControllerBase
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

app4 = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  SessionsController.new(req, res).start
  res.finish
end


$users = [
  { id: 1, name: "User 1" },
  { id: 2, name: "User 2" }
]

$posts = [
  { id: 1, user_id: 1, text: "User 1 post" },
  { id: 2, user_id: 2, text: "User 2 post" },
  { id: 3, user_id: 1, text: "User 1 second post" }
]

class PostsController < ControllerBase
  def index

    posts = $posts.select do |post|
      post[:user_id] == Integer(params['user_id'])
    end

    render_content(posts.to_json, "application/json")
  end
end

class UsersController < ControllerBase
  def index
    render_content($users.to_json, "application/json")
  end
end

router = Router.new
router.draw do
  get Regexp.new("^/users$"), UsersController, :index
  get Regexp.new("^/users/(?<user_id>\\d+)/posts$"), PostsController, :index
end

app5 = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

Rack::Server.start(
 app: app,
 Port: 3000
)

require 'rack'
require_relative '../lib/controller_base'
require_relative '../lib/session'
require_relative '../lib/router'

class TestsController < ControllerBase
  def start
    if @req.path == "/test"
      render_content("Test Successful", 'text/html')
    else
      redirect_to("/test")
    end
  end

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

class SessionsController < ControllerBase
  def start
    session["count"] ||= 0
    session["count"] += 1
    if @req.path == "/session"
      render_content("Cookie count: " + session["count"].to_s, 'text/html')
    else
      redirect_to("/session")
    end
  end

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
  get Regexp.new("^/test$"), TestsController, :start
  get Regexp.new("^/template$"), TemplatesController, :start
  get Regexp.new("^/session$"), SessionsController, :start
end


app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  # TestsController.new(req, res).start
  # TemplatesController.new(req, res).start
  # SessionsController.new(req, res).start
  if req.path == "/"
    res['Content-Type'] = 'text/html'
    res.write("Welcome to Wheels, a lightweight web framework inspired by Rails")
  else
    router.run(req, res)
  end
  res.finish
end

Rack::Server.start(
 app: app,
 Port: 3000
)

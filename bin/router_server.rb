require 'rack'
require_relative '../lib/controller_base'
require_relative '../lib/router'


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

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

Rack::Server.start(
 app: app,
 Port: 3000
)

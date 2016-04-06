class Route

  attr_reader :url_pattern, :http_method, :controller_class, :action

  def initialize(url_pattern, http_method, controller_class, action)
    @url_pattern = url_pattern
    @http_method = http_method
    @controller_class = controller_class
    @action = action
  end

  def matches?(req)
    return true if req.path =~ url_pattern && http_method.to_s == req.request_method.downcase
  end

  def run(req, res)
    match_data = url_pattern.match(req.path)
    route_params = {}
    match_data.names.each { |key| route_params[key] = match_data[key] }

    controller_class.new(req, res, route_params).invoke_action(action)
  end

end

class Router

  attr_reader :routes

  def initialize
    @routes = []
  end

  def run(req, res)
    if match(req)
      route = match(req)
      route.run(req, res)
    else
      res.status = 404
      res.write "Route not found"
      res.finish
    end

  end

  def add_route(pattern, http_call, controller_class, action)
    @routes << Route.new(pattern, http_call, controller_class, action)
  end

  methods = [:get, :post, :put, :delete]
  methods.each do |http_call|
    define_method(http_call) do |pattern, controller_class, action|
      add_route(pattern, http_call, controller_class, action)
    end
  end

  def draw(&proc)
    instance_eval(&proc)
  end

  def match(req)
    @routes.each do |route|
      return route if route.matches?(req)
    end
    nil
  end

end

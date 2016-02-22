require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector' #underscore snake case method
require 'erb'
require_relative './session'
require 'byebug'
require_relative './router.rb'

#Controler Base accepts HTTP requests and responses as inputs.

class ControllerBase

  attr_reader :res, :req, :session, :already_rendered, :params

  def initialize(req, res, route_params = {})
    @res = res || Rack::Response.new
    @req = req
    @params = req.params.merge(route_params)
    @already_rendered = false;
  end

  def render_content(content, content_type)
    if(!already_rendered?)
      @already_rendered = true
      @res['Content-Type'] = content_type
      res.write(content)
      res.finish
      session.store_session(res)
    else
      raise "already rendered"
    end
  end

  def render(template_name)
      template_file = "../views/#{self.class.name.underscore}/#{template_name}.html.erb"
      template = ERB.new(File.read(template_file)).result(binding)
      render_content(template, 'text/html')
  end

  def redirect_to(target)
    if(!already_rendered?)
      @res.status = 302
      @res["Location"] = target
      @already_rendered = true
      session.store_session(res)
    else
      raise "already rendered"
    end
  end

  def session
    @session ||= Session.new(@req)
  end

  def invoke_action(action)
    self.send(action)
    render(action.to_s) unless already_rendered?
  end

  def already_rendered?
    already_rendered
  end
end

require 'spec'
require 'rack/test'
require "help/httpd"
require "help/xpath"

Spec::Runner.configure do |conf|
  conf.include Rack::Test::Methods
end

require File.join File.dirname(__FILE__), '..', 'app.rb'
set :environment, :test

def app
  ActionPlan::App
end



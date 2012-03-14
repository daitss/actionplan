require "rubygems"
require "bundler"
Bundler.setup

require 'rspec'
require 'rack/test'
require "help/xpath"

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

require File.join File.dirname(__FILE__), '..', 'app.rb'
set :environment, :test

def app
  Sinatra::Application
end

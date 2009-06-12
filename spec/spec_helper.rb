require "rubygems"

# Add the local gems dir if found within the app root; any dependencies loaded
# hereafter will try to load from the local gems before loading system gems.
if (local_gem_dir = File.join(File.dirname(__FILE__), '..', 'gems')) && $BUNDLE.nil?
  $BUNDLE = true; Gem.clear_paths; Gem.path.unshift(local_gem_dir)
end

require "merb-core"
require "spec" # Satisfies Autotest and anyone else not using the Rake tasks

# this loads all plugins required in your init file so don't add them
# here again, Merb will do it for you
Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
end

# simple class to assist in having things be available over http
require 'mongrel'


class SimpleHandler < Mongrel::HttpHandler
  attr_reader :body
  attr_writer :body

  def process(request, response)

    response.start(200) do |head, out|
      head["Content-Type"] = "text/xml"
      out.write @body
    end

  end

end

class SpecHttpServer < Mongrel::HttpServer

  def initialize
    super "0.0.0.0", "3003"
  end

  def route(path, data)
    handler = SimpleHandler.new
    handler.body = data
    
    register path, handler
  end

end

# common tasks done on xml
class String
  def format=(format)
    self.sub! /<formatName>.*?<\/formatName>/, "<formatName>#{format}</formatName>"
  end

  def remove_format!
    self.sub! /<formatName>.*?<\/formatName>/, ''
  end

  def audio_codec=(codec)
    self.sub! /<audioDataEncoding>.*?<\/audioDataEncoding>/, "<audioDataEncoding>#{codec} blah blah blah</audioDataEncoding>"
  end

  def remove_audio_codec!
    self.sub! /<audioDataEncoding>.*?<\/audioDataEncoding>/, ''
  end

  def illform!
    self.sub! '/>', '>'
  end

end

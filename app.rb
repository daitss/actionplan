# # action plan to html stylesheet
# stylesheet_file = File.join Merb.root, 'public', 'xsl', 'action_plan_xml_to_html.xsl'
# stylesheet_doc = XML::Document.file stylesheet_file
# $action_plan_to_html = LibXSLT::XSLT::Stylesheet.new stylesheet_doc

require "cgi"
require "net/http"
require 'libxml'

include LibXML
XML::Error.set_handler &XML::Error::QUIET_HANDLER

# load the action plans
require 'actionplan'
load_action_plans! File.join File.dirname(__FILE__), 'public', 'plans'

require 'sinatra'

class ActionPlanD < Sinatra::Default
  
  set :root, File.dirname(__FILE__)

  helpers do

    def fetch_premis_object u
      url = URI.parse CGI::unescape(u)

      case url.scheme
      when "http"
        response = Net::HTTP.get_response url
        XML::Parser.string(response.body).parse

      when "file"
        XML::Parser.file(url.path).parse

      end

    end

    def xml_value_of doc, xpath
      node = doc.find_first xpath, 'p' => 'info:lc/xmlns/premis-v2', 'aes' => 'http://www.aes.org/audioObject'
      node.content.strip rescue nil    
    end

    def extract_format doc
      xml_value_of doc, '//p:format/p:formatDesignation/p:formatName'
    end

    def extract_format_version doc
      xml_value_of doc, '//p:format/p:formatDesignation/p:formatVersion'
    end

    def extract_codec doc
      codecs = xml_value_of doc, '//p:objectCharacteristicsExtension/aes:audioObject/aes:audioDataEncoding'
      codec = codecs.split(' ').first rescue nil
    end

    def find_action_plan format, version
      potential_plans = $plans.select { |p| p.format == format }

      unless potential_plans.empty?

        if version
          potential_plans.find { |p| p.format_version == version }
        else
          potential_plans.sort { |a,b| a.format_version <=> b.format_version }.last
        end

      end

    end

  end

  get '/index' do
    # TODO list everything under /plans
  end

  get '/instructions' do
    halt 400, 'description required' unless params[:description]

    doc = begin 
      fetch_premis_object params[:description]
    rescue
      halt 400, 'must be an xml document' unless doc
    end

    format = extract_format doc
    halt 400, "format missing" unless format
    version = extract_format_version doc
    action_plan = find_action_plan format, version
    not_found "Action Plan for #{format} #{version} cannot be found" unless action_plan

    @instructions = case format
    when 'WAVE', 'AIFF'
      codec = extract_codec doc
      raise BadRequest, "codec is required for #{format} it was not found" unless codec
      action_plan.instructions_with_codec codec

    when /JP2/, 'JPEG'
      action_plan.generic_instructions

    when 'UTF-8', 'ASCII'
      action_plan.generic_instructions

    when 'PDF'
      action_plan.generic_instructions

    else
      []

    end

    erb :instructions
  end
  
end

ActionPlanD.run! if __FILE__ == $0


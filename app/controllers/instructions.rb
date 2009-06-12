require 'xml'
require 'libxml'
require 'libxslt'

class Instructions < Application

  only_provides :xml

  # GET /instructions
  def index
    raise BadRequest, "description query parameter required" unless params[:description]

    url = URI.parse(params[:description])
    XML::Error.set_handler(&XML::Error::QUIET_HANDLER)

    doc = case url.scheme
          when "http"
            response = Net::HTTP.get_response url
            XML::Parser.string(response.body).parse

          when "file"
            XML::Parser.file(url.path).parse

          end

    # extract the format
    format_xpath = '//p:format/p:formatDesignation/p:formatName'
    format_node = doc.find_first format_xpath, NS_PREFIXES
    raise BadRequest, "#{format_xpath} not found" unless format_node
    format = format_node.content.strip

    # extract the format version
    version_xpath = '//p:format/p:formatDesignation/p:formatVersion'
    version_node = doc.find_first version_xpath, NS_PREFIXES
    format_version = if version_node
                       version_node.content.strip
                     else
                       nil
                     end

    # find the apropriate action plan for this format
    potential_plans = $plans.select { |p| p.format == format }
    raise NotFound, "Action Plan for #{format} cannot be found" if potential_plans.empty?

    action_plan = if format_version
                    potential_plans.find { |p| p.format_version == format_version }
                  else
                    sorted = potential_plans.sort { |a,b| a.format_version <=> b.format_version }
                    sorted.last
                  end

    raise NotFound, "Action Plan for #{format} #{format_version} cannot be found" if action_plan.nil?

    @instructions = case format
                    when 'WAVE', 'AIFF'
                      codec_xpath = "//p:objectCharacteristicsExtension/aes:audioObject/aes:audioDataEncoding"
                      codec_node = doc.find_first codec_xpath, NS_PREFIXES
                      raise BadRequest, "#{codec_xpath} not found" unless codec_node
                      codec = codec_node.content.strip.split(' ').first
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

    # render the xml
    render :layout => false

  end

end

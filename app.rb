require "rubygems"
require "bundler/setup"

require 'sinatra'
require 'actionplan'
require 'libxml'
require 'json'
require 'haml'

include LibXML

get '/index' do
  # TODO form
  # TODO list everything under /plans
end

NS_MAP = {
  'p' => 'info:lc/xmlns/premis-v2',
  'aes' => 'http://www.aes.org/audioObject'
}

post %r{/(migration|normalization|xmlresolution)} do |type|
  error 400, 'object is required' unless params[:object]

  doc = begin
          XML::Document.string params[:object]
        rescue => e
          error 400, e.message
        end

  # object identification
  @object_id_type = begin
                      xpath = %Q{//p:object/p:objectIdentifier/p:objectIdentifierType}
                      doc.find_first(xpath, NS_MAP).content
                    rescue
                      error 400, 'object identifier type missing'
                    end

  @object_id_value = begin
                       xpath = %Q{//p:object/p:objectIdentifier/p:objectIdentifierValue}
                       doc.find_first(xpath, NS_MAP).content
                     rescue
                       error 400, 'object identifier value missing'
                     end

  # object format info
  format = doc.find_first('//p:format/p:formatDesignation/p:formatName', NS_MAP).content rescue nil
  format_version =  doc.find_first('//p:format/p:formatDesignation/p:formatVersion', NS_MAP).content rescue nil
  @codec = doc.find_first('//p:objectCharacteristicsExtension/aes:audioObject/aes:audioDataEncoding', NS_MAP).content.split.first rescue nil

  # find the action plan
  potential_plans = ActionPlan::PLANS.select { |p| p.format == format }
  not_found "action plan for #{format} not found" if potential_plans.empty?

  if format_version
    potential_plans.reject! { |p| p.format_version != format_version }
    not_found "action plan for #{format} #{version} not found" if potential_plans.empty?
  else
    potential_plans.reject! { |p| p.format_version }
    not_found "action plan for #{format} not found" if potential_plans.empty?
  end

  @plan = potential_plans.first

  case type

  when 'xmlresolution'
    not_found unless @plan.xmlresolution

  else
    @event_id_type = params['event-id-type'] or error 400, 'event-id-type is required'
    @event_id_value = params['event-id-value'] or error 400, 'event-id-value is required'
    @xform_type = type

    @xform_id = case type
                when 'normalization'
                  @plan.normalization @codec
                when 'migration'
                  @plan.migration @codec
                end

    not_found unless @xform_id
    haml :premis
  end

end

require "rubygems"
require "bundler/setup"

require 'sinatra'
require 'actionplan'
require 'libxml'
require 'json'
require 'haml'

include LibXML

helpers do

  def extract_format_info
    error 400, 'description required' unless params[:description]

    doc = begin
            XML::Document.string params[:description]
          rescue => e
            error 400, e.message
          end

    ns_map = { 'p' => 'info:lc/xmlns/premis-v2', 'aes' => 'http://www.aes.org/audioObject' }
    format = doc.find_first('//p:format/p:formatDesignation/p:formatName', ns_map).content rescue nil
    format_version =  doc.find_first('//p:format/p:formatDesignation/p:formatVersion', ns_map).content rescue nil
    codec = doc.find_first('//p:objectCharacteristicsExtension/aes:audioObject/aes:audioDataEncoding', ns_map).content.split.first rescue nil
    [format, format_version, codec]
  end

  def find_action_plan format, version
    potential_plans = ActionPlan::PLANS.select { |p| p.format == format }
    not_found "action plan for #{format} not found" if potential_plans.empty?

    if version
      potential_plans.reject! { |p| p.format_version != version }
      not_found "action plan for #{format} #{version} not found" if potential_plans.empty?
    else
      potential_plans.reject! { |p| p.format_version} # find the general case plan, i.e. the one with no version
      not_found "action plan for #{format} not found" if potential_plans.empty?
    end

    potential_plans.first
  end

end

get '/index' do
  # TODO list everything under /plans
end

post '/migration' do
  format, format_version, codec = extract_format_info
  plan = find_action_plan format, format_version
  xform_id = plan.migration codec
  not_found unless xform_id

  obj = {
    :plan => { :format => plan.format, :version => plan.format_version, :revision => plan.revision_date },
    :transformation => { :id => xform_id, :type => :normalization, :codec => codec },
    :agent => haml(:agent)
  }

  obj.to_json
end

post '/normalization' do
  format, format_version, codec = extract_format_info
  plan = find_action_plan format, format_version
  xform_id = plan.normalization codec
  not_found unless xform_id

  obj = {
    :plan => { :format => plan.format, :version => plan.format_version, :revision => plan.revision_date },
    :transformation => { :id => xform_id, :type => :normalization, :codec => codec },
    :agent => haml(:agent)
  }

  obj.to_json
end

post '/xmlresolution' do
  format, format_version, codec = extract_format_info
  plan = find_action_plan format, format_version
  not_found unless plan.xmlresolution
end

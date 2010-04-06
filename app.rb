require 'sinatra'
require 'actionplan'

module ActionPlan

  class App < Sinatra::Base

    set :root, File.dirname(__FILE__)

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
        potential_plans = PLANS.select { |p| p.format == format }
        not_found "action plan for #{format} not found" if potential_plans.empty?

        if version
          potential_plans.reject! { |p| p.format_version != version }
          not_found "action plan for #{format} #{version} not found" if potential_plans.empty?
        else
          error 400, "format version is required to determine an action plan" if potential_plans.size > 1
        end

        potential_plans.first
      end

      def xform_redirect url

        if url
          redirect url
        else
          not_found
        end

      end

    end

    get '/index' do
      # TODO list everything under /plans
    end

    post '/migration' do
      format, format_version, codec = extract_format_info
      plan = find_action_plan format, format_version
      m = plan.migration codec
      xform_redirect m
    end

    post '/normalization' do
      format, format_version, codec = extract_format_info
      plan = find_action_plan format, format_version
      n = plan.normalization codec
      xform_redirect n
    end

    post '/xmlresolution' do
      format, format_version, codec = extract_format_info
      plan = find_action_plan format, format_version
      n = plan.xmlresolution
      xform_redirect n
    end

  end

end

ActionPlan::App.run! if __FILE__ == $0

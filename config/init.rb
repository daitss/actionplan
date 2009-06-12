# Go to http://wiki.merbivore.com/pages/init-rb

require 'cgi'

require 'config/dependencies.rb'

use_test :rspec
use_template_engine :erb

Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper

  # cookie session store configuration
  c[:session_secret_key]  = '1f576aed646ad69f34601f56ffaa48ddc077c77b'  # required for cookie session store
  c[:session_id_key] = '_._session_id' # cookie session id key, defaults to "_session_id"
end

Merb::BootLoader.before_app_loads do
  # This will get executed after dependencies have been loaded but
  # before your app's classes have loaded.
  # properly handle names of formats with spaces and dots

  # some common namespace prefixes
  NS_PREFIXES = {
    'p' => 'info:lc/xmlns/premis-v2',
    'aes' => 'http://www.aes.org/audioObject'
  }
end

Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
  # load all the action plans into global variable $plans

  # load the action plans
  plans_dir = File.join Merb.root, 'public', 'plans'
  $plans = []
  pattern = File.join plans_dir, '*.xml'
  raise "no action plans found in #{plans_dir}" if Dir.glob(pattern).empty?

  Dir.glob(pattern).each do |file|

    plan = open(file) do |io|
      
      begin
        ActionPlan.new io.read
      rescue => e
        Merb.logger.error "#{File.basename file} is not valid: #{e.message}"
        exit 1
      end

    end

    if $plans.any? { |p| plan.format == p.format && plan.format_version == p.format_version }
      raise "action plan for #{plan.format} #{plan.format_version} already exists"
    end

    Merb.logger.info "#{plan.format} #{plan.format_version} loaded from #{File.basename file}"
    $plans << plan
  end

  # action plan to html stylesheet
  stylesheet_file = File.join Merb.root, 'public', 'xsl', 'action_plan_xml_to_html.xsl'
  stylesheet_doc = XML::Document.file stylesheet_file
  $action_plan_to_html = LibXSLT::XSLT::Stylesheet.new stylesheet_doc
end

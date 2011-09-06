require "rubygems"
require "bundler/setup"

require 'sinatra'
require 'actionplan'
require 'libxml'
require 'json'
require 'haml'

require 'datyl/logger'
require 'datyl/config'

include LibXML
include Datyl

def get_config
  raise ConfigurationError, "No DAITSS_CONFIG environment variable has been set, so there's no configuration file to read"             unless ENV['DAITSS_CONFIG']

  raise ConfigurationError, "The DAITSS_CONFIG environment variable points to a non-existant file, (#{ENV['DAITSS_CONFIG']})"          unless File.exists? ENV['DAITSS_CONFIG']

  raise ConfigurationError, "The DAITSS_CONFIG environment variable points to a directory instead of a file (#{ENV['DAITSS_CONFIG']})"     if File.directory? ENV['DAITSS_CONFIG']

  raise ConfigurationError, "The DAITSS_CONFIG environment variable points to an unreadable file (#{ENV['DAITSS_CONFIG']})"            unless File.readable? ENV['DAITSS_CONFIG']

  Datyl::Config.new(ENV['DAITSS_CONFIG'], :defaults, ENV['VIRTUAL_HOSTNAME'])
end

configure do |s|
  config = get_config

  ENV['TMPDIR'] = config.temp_directory

  disable :logging        # Stop CommonLogger from logging to STDERR; we'll set it up ourselves.
  disable :dump_errors    # Normally set to true in 'classic' style apps (of which this is one) regardless of :environment; it adds a backtrace to STDERR on all raised errors (even those we properly handle). Not so good.
  set :environment,  :production  # Get some exceptional defaults.
  set :raise_errors, false        # Handle our own exceptions.


  Logger.setup('actionplan', ENV['VIRTUAL_HOSTNAME'])

  if not (config.log_syslog_facility or config.log_filename)
    Logger.stderr # log to STDERR
  end

  Logger.facility = config.log_syslog_facility if config.log_syslog_facility
  Logger.filename = config.log_filename if config.log_filename


  Logger.info "Starting up actionplan service"

  use Rack::CommonLogger, Logger.new(:info, 'Rack:')

end #of configure

error do
  e = @env['sinatra.error']
  request.body.rewind if request.body.respond_to?('rewind') # work around for verbose passenger warning
  Logger.err "Caught exception #{e.class}: '#{e.message}'; backtrace follows", @env
  e.backtrace.each { |line| Logger.err line, @env }

  halt 500, { 'Content-Type' => 'text/plain' }, e.message  "\n"
end 

not_found do
  request.body.rewind if request.body.respond_to?(:rewind)
  content_type 'text/plain'  

  "Not Found\n"
end


get '/index' do
  # TODO form
  # TODO list everything under /plans
end

NS_MAP = {
  'p' => 'info:lc/xmlns/premis-v2',
  'aes' => 'http://www.aes.org/audioObject'
}

get '/status' do
  [ 200, {'Content-Type'  => 'application/xml'}, "<status/>\n" ]
end

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

    {
      'normalization' => @xform_id,
      'codec' => @codec,
      'format' => @plan.format,
      'format version' => @plan.format_version || 'None',
      'revision date' => @plan.revision_date
    }.to_json

  end

end

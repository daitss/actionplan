require 'libxml'
require 'nokogiri'

include LibXML

module ActionPlan

  class Plan

    XML.default_keep_blanks = false
    XML::Error.set_handler &XML::Error::QUIET_HANDLER

    def to_s
      CGI::escape format
    end

    def initialize(source)
      @xml_doc = XML::Parser.string(source).parse
      dtd_file = File.join File.dirname(__FILE__), '..', 'public', 'dtd', 'actionplan.dtd'
      dtd = File.open(dtd_file) { |io| XML::Dtd.new io.read }
      raise 'invalid' unless  @xml_doc.validate(dtd)
    end

    def format
      @xml_doc.find_first('/action-plan/@format').value
    end

    def format_version
      n = @xml_doc.find_first('/action-plan/@format-version')
      n.value if n
    end
    
 
    def to_xml
      @xml_doc.to_s
    end

    def to_html
      # apply the xslt
      xml = Nokogiri::XML @xml_doc.to_s      
      stylesheet = Nokogiri::XSLT(File.read("public/xsl/action_plan_xml_to_html.xsl") 
      # apply the xslt
      stylesheet.transform(xml).to_s
      
    	#$action_plan_to_html.apply(@xml_doc).to_s
	  end
	  
 


  
  end

  BG_REPORT_DIR = File.join File.dirname(__FILE__), '..', 'public', 'bg_reports'

  def load_bg_reports
    pattern = File.join BG_REPORT_DIR, '*.pdf'
    files = Dir[pattern]
    raise "no background report found in #{dir}" if files.empty?

    bg_reports = files.inject([]) do |acc, file|
      report = open(file) { |io| Plan.new io.read }
      raise "#{file} seems to be a duplicate actionplan for #{plan.format}" if acc.any? { |p| p.format == plan.format and p.format_version == plan.format_version }
      acc << report
    end

  end
  module_function :load_bg_reports

  BG_REPORTS = load_bg_reports
end

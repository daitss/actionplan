require 'libxml'
require 'libxslt'

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

    # set the path of the background report for this action plan
    def set_bg_report action_plan_file
      filename = File.basename(action_plan_file, ".xml")
      @bg_report = "/bg_reports/#{filename}.pdf"
    end
    
    def bg_report
      @bg_report
    end
    
    def format
      @xml_doc.find_first('/action-plan/@format').value
    end

    def format_version
      n = @xml_doc.find_first('/action-plan/@format-version')
      n.value if n
    end
    
    def confidence_level
      node= @xml_doc.find_first('/action-plan/confidence-level')
      node.content if node
    end
    
    def implementation_date
      node= @xml_doc.find_first('/action-plan/implementation-date')
      node.content if node
    end
    
    def revision_date
      node = @xml_doc.find_first('/action-plan/revision-date')
      node.content if node
    end
    
    def review_date
      node= @xml_doc.find_first('/action-plan/review-date')
      node.content if node
    end
    
    def next_review
      node = @xml_doc.find_first('/action-plan/next-review')
      node.content if node
    end
    
    def to_xml
      @xml_doc.to_s
    end

    def to_html
      stylesheet_doc = open("public/xsl/to_html.xsl") { |io| LibXML::XML::Document::io io }
      stylesheet = LibXSLT::XSLT::Stylesheet.new stylesheet_doc
      # apply the xslt
      stylesheet.apply(@xml_doc).to_s
      
    	#$action_plan_to_html.apply(@xml_doc).to_s
	  end
	  
    def migration codec=nil

      xpath = if codec
                %Q{//migration/transformation[@codec="#{codec}"]/@id}
              else
                '//migration/transformation[not(@codec)]/@id'
              end

      n = @xml_doc.find_first xpath
      n.value if n
    end

    def normalization codec=nil

      xpath = if codec
                %Q{//normalization/transformation[@codec="#{codec}"]/@id}
              else
                '//normalization/transformation[not(@codec)]/@id'
              end

      n = @xml_doc.find_first xpath
      n.value if n
    end

    def xmlresolution
      n = @xml_doc.find_first '//xmlresolution'
      n.content.strip if n
    end

    def release_date
      Time.parse @xml_doc.find_first('/action-plan/release-date').content
    end

    def revision_date
      @xml_doc.find_first('/action-plan/revision-date').content
    end

  end

  PLANS_DIR = File.join File.dirname(__FILE__), '..', 'public', 'plans'

  def load_action_plans
    pattern = File.join PLANS_DIR, '*.xml'
    files = Dir[pattern]
    raise "no action plans found in #{dir}" if files.empty?

    plans = files.inject([]) do |acc, file|
      plan = open(file) { |io| Plan.new io.read }
      raise "#{file} seems to be a duplicate actionplan for #{plan.format}" if acc.any? { |p| p.format == plan.format and p.format_version == plan.format_version }
      plan.set_bg_report(file)
      acc << plan
    end

  end
  
  module_function :load_action_plans

  PLANS = load_action_plans   
end

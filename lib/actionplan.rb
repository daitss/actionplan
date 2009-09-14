class ActionPlan

  def ActionPlan.first
    $plans.first
  end

  def to_s
    CGI::escape format
  end

  def initialize(source)
    @xml_doc = XML::Parser.string(source).parse

    dtd_file = File.join File.dirname(__FILE__), '..', 'public', 'dtd', 'actionplan.dtd'
    dtd = File.open(dtd_file) { |io| XML::Dtd.new io.read }
    valid_against_dtd = @xml_doc.validate dtd
  end

  def format
    @xml_doc.find_first('/action-plan/@format').value
  end

  def format_version
    x = @xml_doc.find_first('/action-plan/@format-version')

    if x.nil?
      nil
    else
      x.value
    end

  end

  def to_xml
    @xml_doc.to_s
  end

  def to_html
    $action_plan_to_html.apply(@xml_doc).to_s
  end

  def instructions_with_codec(codec)
    full_processing_instructions.map do |type, map|
      ins = {}
      ins[:type] = type
      transformation = map[codec] || map[:all]

      if transformation
        ins[:transformation] = transformation
      else
        ins[:limitation] = "#{codec} is not a supported codec"
      end

      ins
    end
  end

  def generic_instructions
    full_processing_instructions.map do |type, map|
      ins = {}
      ins[:type] = type

      if map[:all]
        ins[:transformation] = map[:all]
      else
        ins[:limitation] = "no generic transformation"
      end

      ins
    end
  end

  def release_date
    Time.parse @xml_doc.find_first('/action-plan/release-date').content
  end

  protected

  def full_processing_instructions
    instructions = {}

    @xml_doc.find('/action-plan/ingest-processing/*[transformation]').each do |pi_tag|
      key = pi_tag.name.downcase

      map = pi_tag.find('transformation').inject({}) do |memo, transformation_tag|
        codec = transformation_tag.attributes['codec'] || :all
        transformation = transformation_tag.attributes['url']
        memo.merge( { codec => transformation } )
      end

      instructions[key] = map
    end

    instructions
  end


end

def load_action_plans! dir
  $plans = []
  pattern = File.join dir, '*.xml'
  raise "no action plans found in #{dir}" if Dir.glob(pattern).empty?

  Dir.glob(pattern).each do |file|

    plan = open(file) do |io|

      begin
        ActionPlan.new io.read
      rescue => e
        raise "#{File.basename file} is not valid: #{e.message}"
        exit 1
      end

    end

    if $plans.any? { |p| plan.format == p.format && plan.format_version == p.format_version }
      raise "action plan for #{plan.format} #{plan.format_version} already exists"
    end

    $plans << plan
  end

end

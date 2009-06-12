require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe 'processing instructions for an aes described file' do

  before(:each) do
    @httpd = SpecHttpServer.new
    @httpd.run

    @description = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<premis xmlns="info:lc/xmlns/premis-v2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <object xsi:type="file">
    <objectCharacteristics>
      <format>
        <formatDesignation>
          <formatName>WAVE</formatName>
        </formatDesignation>
      </format>
      <objectCharacteristicsExtension>
        <audioObject xmlns="http://www.aes.org/audioObject">
          <format>WAVE</format>
          <audioDataEncoding>PCM audio in integer format</audioDataEncoding>
        </audioObject>
      </objectCharacteristicsExtension>
    </objectCharacteristics>
  </object>
</premis>
XML
    handler = SimpleHandler.new
    handler.body = @description
    path = "/the_description_info"
    @httpd.register path, handler
    
    @url = "http://#{@httpd.host}:#{@httpd.port}#{path}"
  end
  
  after(:each) do
    @httpd.stop
  end
  
  it 'should fail when a codec does not exists' do
    @description.remove_audio_codec!
    response = request("/instructions", :params => { :description => CGI::escape(@url), :format => :xml })
    response.should_not be_successful
    response.status.should == 400
  end
  
  it "should specify a limitation for a non-supported coded" do
    @description.audio_codec = "XXX"
    response = request("/instructions", :params => { :description => CGI::escape(@url) })
    response.should be_successful
    response.should have_xpath('//p:limitation', NS_PREFIXES)
  end
  
  it "should default to a transformation when applicable" do

    # make sure there exists a transformation with no codec
    wave_plan = $plans.find { |p| p.format == 'WAVE' }
    wave_plan.instance_eval { @xml_doc.find_first('//transformation').attributes.get_attribute('codec').remove!  }
    
    @description.audio_codec = "XXX"
    response = request("/instructions", :params => { :description => CGI::escape(@url) })
    response.should be_successful
    response.should have_xpath('//p:transformation', NS_PREFIXES)    
  end
  
end

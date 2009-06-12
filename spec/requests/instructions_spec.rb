require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given 'a premis object' do

  @description =<<XML
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
  @description_url = "http://#{@httpd.host}:#{@httpd.port}#{path}"
end

describe "/instructions" do

  before(:each) do    
    @httpd = Mongrel::HttpServer.new "0.0.0.0", "3003"
    @httpd.run
  end
  
  after(:each) do
    @httpd.stop
  end
  
  describe "a good processing instruction request", :given => 'a premis object' do

    before(:each) do
      @response = request("/instructions", :params => { :description => CGI::escape(@description_url) })
    end

    it "should respond successfully" do
      @response.should be_successful
    end

    it "should be a premis document" do
      @response.should have_xpath('/p:premis', NS_PREFIXES)
    end

    it "should contain a premis agent" do
      @response.should have_xpath('/p:premis/p:agent', NS_PREFIXES)
    end

    it "should contain a premis event" do
      @response.should have_xpath('/p:premis/p:event', NS_PREFIXES)
    end

    it "should contain normalizations or migrations" do
      @response.should have_xpath('//p:eventOutcomeDetail/p:normalization|p:migration', NS_PREFIXES)
    end

    it "should contain limitations or transformations" do
      @response.should have_xpath('//p:limitation|//p:transformation', NS_PREFIXES)
    end

  end

  describe "a failed processing instruction request", :given => 'a premis object' do
    
    it "should fail when no url is passed" do
      request("/instructions").should_not be_successful
    end
    
    it "should fail when the description is bad" do
      @description.illform!
      response = request("/instructions")
      response.should_not be_successful
      response.status.should == 400
    end
    
    it "should fail when a format cannot be determined" do
      @description.remove_format! 
      response = request("/instructions", :params => { :description => CGI::escape(@description_url) })
      response.should_not be_successful
      response.status.should == 400
    end
    
    it "should be not found when an action plan does not exist for a format" do
      @description.format = 'XXX'
      response = request "/instructions", :params => { :description => CGI::escape(@description_url) }
      response.should_not be_successful
      response.status.should == 404
    end
    
  end
  
end


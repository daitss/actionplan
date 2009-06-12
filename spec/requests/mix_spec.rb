describe 'processing instructions for an mix described file' do
  
  before(:each) do    
    @httpd = Mongrel::HttpServer.new "0.0.0.0", "3000"
    @httpd.run
  end
  
  after(:each) do
    @httpd.stop
  end
  
  it 'should pass with just the format name' do
    handler = SimpleHandler.new
    handler.body = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<premis xmlns="info:lc/xmlns/premis-v2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <object xsi:type="file">
    <objectCharacteristics>
      <format>
        <formatDesignation>
          <formatName>JPEG 2000</formatName>
          <formatVersion>1.0</formatVersion>
        </formatDesignation>
      </format>
      <objectCharacteristicsExtension>
      </objectCharacteristicsExtension>
    </objectCharacteristics>
  </object>
</premis>
XML
    path = "/the_description_info"
    @httpd.register path, handler
    url = "http://#{@httpd.host}:#{@httpd.port}#{path}"
    
    response = request("/instructions", :params => { :description => CGI::escape(url) })
    response.should be_successful
  end
  
end

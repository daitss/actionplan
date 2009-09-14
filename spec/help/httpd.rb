require 'mock_server'

FIXTURES = {}
FIXTURES[:good]=<<XML
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

FIXTURES[:illformed] = FIXTURES[:good].sub '</', '<'
FIXTURES[:missing_format] = FIXTURES[:good].sub /<formatName>.*?<\/formatName>/, ''
FIXTURES[:unknown_format] = FIXTURES[:good].sub /<formatName>.*?<\/formatName>/, "<formatName>XXX</formatName>"

TEST_PORT=4000

include MockServer::Methods

mock_server do
  
  get "/:name" do
    FIXTURES[params[:name].intern]
  end
  
end

def fixture_url name
  raise 'unknown key' unless FIXTURES.has_key? name
  "http://localhost:#{TEST_PORT}/#{name}"
end

require 'cgi'
def escaped_fixture_url name
  CGI::escape fixture_url(name)
end

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

# TODO refactor when we have some more or a period of time passes
describe 'regression behavior' do

  before do
    @httpd = SpecHttpServer.new
    @httpd.run
  end

  after do
    @httpd.stop
  end
  
  it "should grok format version" do
    path = "/premisobject"
    @httpd.route path, <<CAROL
<premis xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:schemaLocation='info:lc/xmlns/premis-v2 http://www.loc.gov/standards/premis/draft-schemas-2-0/premis-v2-0.xsd' version='2.0' xmlns='info:lc/xmlns/premis-v2'><object xsi:type='file'><objectIdentifier><objectIdentifierType>DAITSS2</objectIdentifierType><objectIdentifierValue>/Users/Carol/Workspace/perfile/UFE0011427/etd.pdf</objectIdentifierValue></objectIdentifier><objectCharacteristics><compositionLevel>0</compositionLevel><size>3312509</size><format><formatDesignation><formatName>PDF</formatName><formatVersion>1.3</formatVersion></formatDesignation><formatRegistry><formatRegistryName>PRONOM</formatRegistryName><formatRegistryKey>fmt/17</formatRegistryKey></formatRegistry></format><creatingApplication><creatingApplicationName>
      </creatingApplicationName><dateCreatedByApplication>
      </dateCreatedByApplication></creatingApplication><fixity><messageDigestAlgorithm>MD5</messageDigestAlgorithm><messageDigest>6bf12f206a3e70c88cfe2aa5213dd227</messageDigest></fixity><objectCharacteristicsExtension><DocMD xmlns='http://fda.fcla.edu/DocMD.xsd'><document><NumOfPage>123</NumOfPage><UnembeddedFont>
          Arial
         </UnembeddedFont><UnembeddedFont>
          TimesNewRoman,BoldItalic
         </UnembeddedFont><UnembeddedFont>
          BookmanOldStyle
         </UnembeddedFont><UnembeddedFont>
          Arial,Bold
         </UnembeddedFont><UnembeddedFont>
          TimesNewRoman,Italic
         </UnembeddedFont><Feature>Outlined</Feature><Feature>Thumbnailed</Feature></document></DocMD></objectCharacteristicsExtension></objectCharacteristics></object><event><eventIdentifier><eventIdentifierType>DAITSS2</eventIdentifierType><eventIdentifierValue>1</eventIdentifierValue></eventIdentifier><eventType>Format Description</eventType><eventDateTime>2009-02-26T11:38:45</eventDateTime><eventOutcomeInformation><eventOutcome>Well-Formed, but not valid</eventOutcome><eventOutcomeDetail><eventOutcomeDetailExtension><anomaly>Invalid destination object</anomaly></eventOutcomeDetailExtension></eventOutcomeDetail></eventOutcomeInformation></event><agent><agentIdentifier><agentIdentifierType>uri</agentIdentifierType><agentIdentifierValue>http://localhost:3002/describe</agentIdentifierValue></agentIdentifier><agentName>Format Description Service</agentName><agentType>Web Service</agentType></agent></premis>
CAROL

    url = "http://#{@httpd.host}:#{@httpd.port}#{path}"
    response = request("/instructions", :params => { :description => CGI::escape(url) }, :format => :xml)
    response.should be_successful
  end

end

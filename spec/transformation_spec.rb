require 'spec_helper'
require 'json'

shared_examples_for "any transformation" do

  it "should 400 when missing event identifier" do
    post @url, :object => 'foo'
    last_response.status.should == 400
  end

  it "should 400 when missing description" do
    post @url
    last_response.status.should == 400
  end

  it "should 400 when bad object" do
    post @url, :object => "<premis>foo<premis>"
    last_response.status.should == 400
  end

  it "should 404 when actionplan does not exist" do

    premis_object = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<object xmlns="http://www.loc.gov/premis/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="file">
  <objectIdentifier>
    <objectIdentifierType>URI</objectIdentifierType>
    <objectIdentifierValue>sha1:7ac8b064b38fe4d42f1b04ea45e43f71</objectIdentifierValue>
  </objectIdentifier>
  <objectCharacteristics>
    <compositionLevel>0</compositionLevel>
    <fixity>
      <messageDigestAlgorithm>MD5</messageDigestAlgorithm>
      <messageDigest>7ac8b064b38fe4d42f1b04ea45e43f71</messageDigest>
    </fixity>
    <size>5138268</size>
    <format>
      <formatDesignation>
        <formatName>XXX</formatName>
        <formatVersion>1.5</formatVersion>
      </formatDesignation>
    </format>
  </objectCharacteristics>
  <originalName>mimi.pdf</originalName>
</object>
    XML

    post @url, :object => premis_object, 'event-id-type' => 'URI', 'event-id-value' => 'foo:bar:22'
    last_response.status.should == 404
  end

  it "should 404 when transformation does not exist" do

    premis_object = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<object xmlns="http://www.loc.gov/premis/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="file">
  <objectIdentifier>
    <objectIdentifierType>URI</objectIdentifierType>
    <objectIdentifierValue>sha1:7ac8b064b38fe4d42f1b04ea45e43f71</objectIdentifierValue>
  </objectIdentifier>
  <objectCharacteristics>
    <compositionLevel>0</compositionLevel>
    <fixity>
      <messageDigestAlgorithm>MD5</messageDigestAlgorithm>
      <messageDigest>7ac8b064b38fe4d42f1b04ea45e43f71</messageDigest>
    </fixity>
    <size>5138268</size>
    <format>
      <formatDesignation>
        <formatName>JPEG</formatName>
        <formatVersion>1.01</formatVersion>
      </formatDesignation>
    </format>
  </objectCharacteristics>
  <originalName>mimi.pdf</originalName>
</object>
    XML

    post @url, :object => premis_object, 'event-id-type' => 'URI', 'event-id-value' => 'foo:bar:22'
    last_response.status.should == 404
  end

  # actionplan exists
  # transformation exists
  # format version exists
  # codec exists

  it "should 404 if version is needed and not supplied" do

    premis_object = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<object xmlns="http://www.loc.gov/premis/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="file">
  <objectIdentifier>
    <objectIdentifierType>URI</objectIdentifierType>
    <objectIdentifierValue>sha1:7ac8b064b38fe4d42f1b04ea45e43f71</objectIdentifierValue>
  </objectIdentifier>
  <objectCharacteristics>
    <compositionLevel>0</compositionLevel>
    <fixity>
      <messageDigestAlgorithm>MD5</messageDigestAlgorithm>
      <messageDigest>7ac8b064b38fe4d42f1b04ea45e43f71</messageDigest>
    </fixity>
    <size>5138268</size>
    <format>
      <formatDesignation>
        <formatName>PDF</formatName>
      </formatDesignation>
    </format>
  </objectCharacteristics>
  <originalName>mimi.pdf</originalName>
</object>
    XML

    post @url, :object => premis_object, 'event-id-type' => 'URI', 'event-id-value' => 'foo:bar:22'
    last_response.status.should == 404
  end

  it "should 404 if codec is needed and not supplied" do

    premis_object = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<object xmlns="http://www.loc.gov/premis/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="file">
  <objectIdentifier>
    <objectIdentifierType>URI</objectIdentifierType>
    <objectIdentifierValue>sha1:7ac8b064b38fe4d42f1b04ea45e43f71</objectIdentifierValue>
  </objectIdentifier>
  <objectCharacteristics>
    <compositionLevel>0</compositionLevel>
    <fixity>
      <messageDigestAlgorithm>MD5</messageDigestAlgorithm>
      <messageDigest>7ac8b064b38fe4d42f1b04ea45e43f71</messageDigest>
    </fixity>
    <size>5138268</size>
    <format>
      <formatDesignation>
        <formatName>WAVE</formatName>
      </formatDesignation>
    </format>
  </objectCharacteristics>
  <originalName>mimi.pdf</originalName>
</object>
    XML

    post @url, :object => premis_object, 'event-id-type' => 'URI', 'event-id-value' => 'foo:bar:22'
    last_response.status.should == 404
  end

end

describe "/migration" do
  before(:all) { @url = "/migration" }

  it_should_behave_like "any transformation"

  it "should return proper transformation and actionplan info" do
    pending "no migrations defined in any actionplan yet"
  end

end

describe "/normalization" do
  before(:all) { @url = "/normalization" }

  it_should_behave_like "any transformation"

  it "should return wave_norm transformation and actionplan info for wave" do
    premis_object = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<object xmlns="http://www.loc.gov/premis/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="file">
  <objectIdentifier>
    <objectIdentifierType>URI</objectIdentifierType>
    <objectIdentifierValue>sha1:7ac8b064b38fe4d42f1b04ea45e43f71</objectIdentifierValue>
  </objectIdentifier>
  <objectCharacteristics>
    <compositionLevel>0</compositionLevel>
    <fixity>
      <messageDigestAlgorithm>MD5</messageDigestAlgorithm>
      <messageDigest>7ac8b064b38fe4d42f1b04ea45e43f71</messageDigest>
    </fixity>
    <size>5138268</size>
    <format>
      <formatDesignation>
        <formatName>Waveform Audio</formatName>
      </formatDesignation>
    </format>
    <objectCharacteristicsExtension>
      <audioObject xmlns="http://www.aes.org/audioObject">
        <audioDataEncoding>PCM</audioDataEncoding>
      </audioObject>
    </objectCharacteristicsExtension>

  </objectCharacteristics>
  <originalName>mimi.pdf</originalName>
</object>
    XML

    post @url, :object => premis_object, 'event-id-type' => 'URI', 'event-id-value' => 'foo:bar:22'
    last_response.should be_ok
    json = JSON.parse last_response.body
    json['normalization'].should == 'wave_norm'
    json['codec'].should == 'PCM'
    json['format'].should == 'Waveform Audio'
    json['format version'].should == 'None'
    json['revision date'].should == '2012.08.01'
  end

   it "should return mov_norm transformation and actionplan info for mov" do
      premis_object = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<object xmlns="http://www.loc.gov/premis/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="file">
		<objectIdentifier>
		<objectIdentifierType>URI</objectIdentifierType>
		<objectIdentifierValue>http://www.fcla.edu/daitss-test/files/thesis.mov</objectIdentifierValue>
	</objectIdentifier>
	<objectCharacteristics>
		<compositionLevel>0</compositionLevel>
		<fixity>
			<messageDigestAlgorithm>MD5</messageDigestAlgorithm>
			<messageDigest>7c1678bf6018a79aa97be2747594cfbe</messageDigest>
			<messageDigestOriginator>Archive</messageDigestOriginator>
		</fixity>
		<fixity>
			<messageDigestAlgorithm>SHA-1</messageDigestAlgorithm>
			<messageDigest>0227fcafc39a1265deb097b914d3335945623037</messageDigest>
			<messageDigestOriginator>Archive</messageDigestOriginator>
		</fixity>
		<size>1400682</size>
		
		<format>
			<formatDesignation>
				<formatName>Quicktime</formatName>
				
			</formatDesignation>
			
			<formatRegistry>
				<formatRegistryName>http://www.nationalarchives.gov.uk/pronom</formatRegistryName>
				<formatRegistryKey>x-fmt/384</formatRegistryKey>
			</formatRegistry>	
		</format>
		
	</objectCharacteristics>
	
	<originalName>/daitss-test/files/thesis.mov</originalName>
</object>
      XML

      post @url, :object => premis_object, 'event-id-type' => 'URI', 'event-id-value' => 'foo:bar:22'
      last_response.should be_ok
      json = JSON.parse last_response.body
      json['normalization'].should == 'mov_norm'
      json['format'].should == 'Quicktime'
      json['format version'].should == 'None'
    end

       it "should return avi_norm transformation and actionplan info for avi" do
          premis_object = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<object xmlns="http://www.loc.gov/premis/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="file">
	<objectIdentifier>
	<objectIdentifierType>URI</objectIdentifierType>
	<objectIdentifierValue>http://www.fcla.edu/daitss-test/files/video.avi</objectIdentifierValue>
</objectIdentifier>
<objectCharacteristics>
	<compositionLevel>0</compositionLevel>
	<fixity>
		<messageDigestAlgorithm>MD5</messageDigestAlgorithm>
		<messageDigest>7c6d81db8e7aa247360f0f0d2b7da0fb</messageDigest>
		<messageDigestOriginator>Archive</messageDigestOriginator>
	</fixity>
	<fixity>
		<messageDigestAlgorithm>SHA-1</messageDigestAlgorithm>
		<messageDigest>c4b51c9346b4eec3b461482bb11082b0f618fffe</messageDigest>
		<messageDigestOriginator>Archive</messageDigestOriginator>
	</fixity>
	<size>5967872</size>
	
	<format>
		<formatDesignation>
			<formatName>Audio/Video Interleaved Format</formatName>
			
		</formatDesignation>
		
		<formatRegistry>
			<formatRegistryName>http://www.nationalarchives.gov.uk/pronom</formatRegistryName>
			<formatRegistryKey>fmt/5</formatRegistryKey>
		</formatRegistry>
		
		
	</format>
	
	
	
	
</objectCharacteristics>

<originalName>/daitss-test/files/video.avi</originalName>
</object>
      XML

          post @url, :object => premis_object, 'event-id-type' => 'URI', 'event-id-value' => 'foo:bar:22'
          last_response.should be_ok
          json = JSON.parse last_response.body
          json['normalization'].should == 'avi_norm'
          json['format'].should == 'Audio/Video Interleaved Format'
          json['format version'].should == 'None'
        end

end

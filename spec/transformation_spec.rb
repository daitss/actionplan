require 'spec_helper'

shared_examples_for "any transformation" do

  it "should 400 when missing description" do
    post @url
    last_response.status.should == 400
  end

  it "should 400 when bad description" do
    post @url, :description => "<premis>foo<premis>"
    last_response.status.should == 400
  end

  it "should 404 when actionplan does not exist" do

    premis_object = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<object xmlns="info:lc/xmlns/premis-v2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="file">
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

    post @url, :description => premis_object
    last_response.status.should == 404
  end

  it "should 404 when transformation does not exist" do

    premis_object = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<object xmlns="info:lc/xmlns/premis-v2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="file">
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

    post @url, :description => premis_object
    last_response.status.should == 404
  end

  # actionplan exists
  # transformation exists
  # format version exists

  # format version does not exist
  it "should 400 is version is needed and not supplied" do

    premis_object = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<object xmlns="info:lc/xmlns/premis-v2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="file">
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

    post @url, :description => premis_object
    last_response.status.should ==  400
  end

  # codec exists
  # codec does not exist
end

describe "/migration" do
  before(:all) { @url = "/migration" }
  it_should_behave_like "any transformation"
end

describe "/normalization" do
  before(:all) { @url = "/normalization" }
  it_should_behave_like "any transformation"

end

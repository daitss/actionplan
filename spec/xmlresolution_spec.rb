require 'spec_helper'

describe "/xmlresolution" do

  it "should redirect a file object that should be resolved" do

    premis_object =<<-XML
<?xml version="1.0" encoding="UTF-8"?>
      <object xmlns="info:lc/xmlns/premis-v2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="file">
        <objectIdentifier>
          <objectIdentifierType>URI</objectIdentifierType>
          <objectIdentifierValue>test:/3dccd630-fe28-012c-8021-001b63b4d6a3/file/1</objectIdentifierValue>
        </objectIdentifier>
        <objectCharacteristics>
          <compositionLevel>0</compositionLevel>
          <fixity>
            <messageDigestAlgorithm>MD5</messageDigestAlgorithm>
            <messageDigest>36fcbd5a99476be81b1cae575236c073</messageDigest>
          </fixity>
          <size>1050</size>
          <format>
            <formatDesignation>
              <formatName>Extensible Markup Language</formatName>
              <formatVersion>1.0</formatVersion>
            </formatDesignation>
            <formatRegistry>
              <formatRegistryName>http://www.nationalarchives.gov.uk/pronom</formatRegistryName>
              <formatRegistryKey>fmt/101</formatRegistryKey>
            </formatRegistry>
          </format>
          <objectCharacteristicsExtension>
            <textMD xmlns="http://www.loc.gov/standards/textMD">
              <encoding>
                <encoding_platform linebreak="CR/LF"/>
              </encoding>
              <character_info>
                <charset>UTF-8</charset>
                <linebreak>CR/LF</linebreak>
              </character_info>
              <language>
                <markup_basis>XML</markup_basis>
                <markup_language>http://www.loc.gov/METS/</markup_language>
                <processingNote/>
              </language>
            </textMD>
          </objectCharacteristicsExtension>
        </objectCharacteristics>
        <originalName>mimi.xml</originalName>
        <linkingEventIdentifier>
          <linkingEventIdentifierType>URI</linkingEventIdentifierType>
          <linkingEventIdentifierValue>test:/3dccd630-fe28-012c-8021-001b63b4d6a3/file/1/event/describe/0</linkingEventIdentifierValue>
        </linkingEventIdentifier>
      </object>
    XML

    post "/xmlresolution", :object => premis_object
    last_response.should be_ok
  end

  it "should not redirect a file object that should not be resolved" do

    premis_object =<<-PDF
<?xml version="1.0" encoding="UTF-8"?>
      <object xmlns="info:lc/xmlns/premis-v2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="file">
        <objectIdentifier>
          <objectIdentifierType>URI</objectIdentifierType>
          <objectIdentifierValue>test:/3dccd630-fe28-012c-8021-001b63b4d6a3/file/0</objectIdentifierValue>
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
              <formatVersion>1.5</formatVersion>
            </formatDesignation>
            <formatRegistry>
              <formatRegistryName>http://www.nationalarchives.gov.uk/pronom</formatRegistryName>
              <formatRegistryKey>fmt/19</formatRegistryKey>
            </formatRegistry>
          </format>
          <creatingApplication>
            <creatingApplicationName>Adobe PDF library 9.00</creatingApplicationName>
            <dateCreatedByApplication>2010-01-12T10:38:38-05:00</dateCreatedByApplication>
          </creatingApplication>
          <objectCharacteristicsExtension>
            <doc xmlns="http://www.fcla.edu/dls/md/docmd">
              <document>
                <PageCount>1</PageCount>
                <Feature>hasThumbnails</Feature>
              </document>
            </doc>
          </objectCharacteristicsExtension>
        </objectCharacteristics>
        <originalName>mimi.pdf</originalName>
        <relationship>
          <relationshipType>structural</relationshipType>
          <relationshipSubType>includes</relationshipSubType>
          <relatedObjectIdentification>
            <relatedObjectIdentifierType>URI</relatedObjectIdentifierType>
            <relatedObjectIdentifierValue>test:/3dccd630-fe28-012c-8021-001b63b4d6a3/file/0/1</relatedObjectIdentifierValue>
          </relatedObjectIdentification>
        </relationship>
        <linkingEventIdentifier>
          <linkingEventIdentifierType>URI</linkingEventIdentifierType>
          <linkingEventIdentifierValue>test:/3dccd630-fe28-012c-8021-001b63b4d6a3/file/0/event/describe/0</linkingEventIdentifierValue>
        </linkingEventIdentifier>
      </object>
    PDF

    post  '/xmlresolution', :object => premis_object
    last_response.should_not be_ok
  end

end

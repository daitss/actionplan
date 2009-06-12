require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe ActionPlan do

  before(:each) do
    @string_source = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<action-plan format="TBD">
        <implementation-date>TBD</implementation-date>
        <release-date>TBD</release-date>
        <revision-date>TBD</revision-date>
        <ingest-processing>
                <identification>the identification</identification>
                <validation>the validation</validation>
                <characterization>the characterization</characterization>
                <migration>the migration</migration>
                <normalization>
                  the normalization
                  <transformation url="http://transformation/something_norm"/>
                  <transformation codec="FOO" url="http://transformation/something_norm_foo"/>
          </normalization>
        </ingest-processing>
        <significant-properties>
                <content>TBD</content>
                <context>TBD</context>
                <behavior>TBD</behavior>
                <structure>TBD</structure>
                <appearance>TBD</appearance>
        </significant-properties>
        <long-term-strategy>
                <original>
                        TBD
                </original>
        </long-term-strategy>
        <short-term-actions>
                <action>TBD</action>
        </short-term-actions>
</action-plan>
XML
    @string_io_source = StringIO.new @string_source
    @action_plan = ActionPlan.new @string_source
  end

  it "should accept xml as a String or something readable" do
    lambda {ActionPlan.new @string_source}.should_not raise_error
  end

  it "should have a format" do
    @action_plan.format.should == 'TBD'
  end

  it "should have a release date" do
    @action_plan.release_date.should be_kind_of(Time)
  end

  it "should not initialize from an invalid source" do
    invalid_source = @string_source.sub('</action-plan', '<action-plan')
    lambda { ActionPlan.new invalid_source }.should raise_error(LibXML::XML::Error, /Fatal error: Premature end of data in tag action-plan/)

    invalid_source = @string_source.gsub('action', 'XXX')
    lambda { ActionPlan.new invalid_source }.should raise_error(LibXML::XML::Error, /Error: No declaration for element XXX/ )
  end

  it "should have processing instructions" do
    @action_plan.generic_instructions.should == [{:type => 'normalization', :transformation => 'http://transformation/something_norm'}]
  end

  it "should have codec specific instructions" do
    @action_plan.instructions_with_codec("FOO").should == [{:type => 'normalization', :transformation => 'http://transformation/something_norm_foo'}]
  end

end

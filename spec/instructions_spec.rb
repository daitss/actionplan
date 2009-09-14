require 'spec_helper'

describe "a good instruction request" do

  before(:each) do
    get "/instructions", :description => escaped_fixture_url(:good)
  end

  it "should respond successfully" do
    last_response.status.should == 200
  end

  it "should be a premis document" do
    last_response.should have_xpath('/p:premis')
  end

  it "should contain a premis agent" do
    last_response.should have_xpath '/p:premis/p:agent'
  end

  it "should contain a premis event" do
    last_response.should have_xpath '/p:premis/p:event'
  end

  it "should contain normalizations or migrations" do
    last_response.should have_xpath '//p:eventOutcomeDetailExtension/p:normalization|p:migration'
  end

  it "should contain limitations or transformations" do
    last_response.should have_xpath '//p:limitation|//p:transformation'
  end

end

describe "a failed processing instruction request" do

  it "should fail when no url is passed" do
    get "/instructions"
    last_response.status.should == 400
  end

  it "should fail when the description is bad" do
    get "/instructions", :description => escaped_fixture_url(:illformed)
    last_response.status.should == 400
  end

  it "should fail when a format cannot be determined" do
    get "/instructions", :description => escaped_fixture_url(:missing_format)
    last_response.status.should == 400
  end

  it "should be not found when an action plan does not exist for a format" do
    get "/instructions", :description => escaped_fixture_url(:unknown_format)
    last_response.status.should == 404      
  end

end

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "resource(:action_plans)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:action_plans))
    end

    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of action_plans" do
      @response.should have_xpath("//ul")
    end

    it "has a list of action_plans" do
      @response.should have_xpath("//ul/li")
    end
    
  end  
  
end

describe "resource(@action_plan)" do
  
  describe "GET" do
    
    it "responds successfully" do
      $plans.each do |plan|
        @response = request(resource(:action_plans, :id =>  CGI::escape(plan.format),  :formatversion => plan.format_version))
        @response.should be_successful
      end
      
    end
    
  end
  
end

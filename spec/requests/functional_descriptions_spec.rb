describe 'description service output examples' do

  before do
    @httpd = Mongrel::HttpServer.new "0.0.0.0", "3000"
    @httpd.run
  end
  
  after do
    @httpd.stop
  end
  
  
  it "no description should cause a server error" do

    pending "needs some attention"
    
    pattern = File.join Merb.root, 'spec', 'premis-objects', '*'

    paths = []
    
    Dir[pattern].each do |file|
      handler = SimpleHandler.new
      handler.body = open(file).read
      path = '/' +  File.basename(file)[0...(File.extname(file).length * -1)]
      paths << path
      @httpd.register path, handler
    end

    paths.each do |path|
      url = "http://#{@httpd.host}:#{@httpd.port}#{path}"
      response = request("/instructions", :params => { :description => CGI::escape(url) })
      # TODO get with carol so everything is good

      response.should be_successful
      #(response.status < 500).should be_true
      #response.status.should_not == "404"
    end
    
  end
  
end

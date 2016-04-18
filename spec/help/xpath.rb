require "libxml"

include LibXML

RSpec::Matchers.define :have_xpath do |xpath|
  
  match do |resp|
    doc = XML::Document.string resp.body
    doc.root.find_first xpath, 'p' => 'http://www.loc.gov/premis/v3', 'aes' => 'http://www.aes.org/audioObject'
  end
  
  failure_message_for_should do |resp|
    "expected following xml to match #{xpath}\n#{resp.body}"
  end
  
end

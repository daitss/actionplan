require "libxml"

include LibXML

Spec::Matchers.define :have_xpath do |xpath|
  
  match do |resp|
    doc = XML::Document.string resp.body
    doc.root.find_first xpath, 'p' => 'info:lc/xmlns/premis-v2', 'aes' => 'http://www.aes.org/audioObject'
  end
  
  failure_message_for_should do |resp|
    "expected following xml to match #{xpath}\n#{resp.body}"
  end
  
end

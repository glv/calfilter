require 'rubygems'
require 'test/spec'
require 'mocha'

require 'calfilter'

def at_exit(&block)
  $at_exit_block = block
end

describe "calfilter cgi scripts" do
  before(:all) do
    CalFilter::CGI = ''
    require 'calfilter/cgi'
  end
  
  it "should initialize a CFCGI object" do
    assert CalFilter::CGI == ""
  end
  
  xit "should set CalFilter's output stream"
  
  xit "should finish the CGI on process exit"
  
  xit "should write proper output when finishing"
end

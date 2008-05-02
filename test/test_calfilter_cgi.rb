require 'rubygems'
require 'test/spec'
require 'mocha'

require 'calfilter'

CalFilter::CGI = Mocha::Mock.new
def at_exit(&block)
  $at_exit_block = block
end
require 'calfilter/cgi'
class CGI
  def initialize_query
  end
end

describe "calfilter cgi scripts" do
  it "should initialize a CFCGI object" do
    assert_true CalFilter::CFCGI === CalFilter.make_cgi
  end
  
  xit "should set CalFilter's output stream"
  
  xit "should finish the CGI on process exit"
  
  xit "should write proper output when finishing"
end

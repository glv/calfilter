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
  
  it "should initialize a CGIWrapper object" do
    assert_not_nil CalFilter::CGIWrapper
  end
  
  it "should set CalFilter's output stream" do
    assert_not_nil CalFilter::CGIWRAPPER.output_stream
    assert_equal CalFilter::CGIWRAPPER.output_stream, CalFilter.output_stream
  end
  
  it "should finish the CGI on process exit" do
    CalFilter::CGIWRAPPER.expects(:finish)
    $at_exit_block.call
  end
  
  it "should write proper output when finishing" do
    CalFilter::CGI.expects(:out).with('text/calendar; charset=utf-8')
    CalFilter::CGIWRAPPER.finish
  end
end

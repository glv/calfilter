require 'rubygems'
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
    CalFilter::CGIWrapper.should_not be_nil?
  end
  
  it "should set CalFilter's output stream" do
    CalFilter::CGIWRAPPER.output_stream.should_not be_nil?
    CalFilter.output_stream.should == CalFilter::CGIWRAPPER.output_stream
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

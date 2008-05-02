require 'calfilter'
require 'cgi'
require 'stringio'

module CalFilter

  class CGIWrapper
    attr_reader :output_stream
    
    def initialize(output_stream)
      set_cgi_constant
      CalFilter.output_stream = @output_stream = output_stream
    end
    
    def create_cgi_instance
      CGI.new
    end
    
    def set_cgi_constant
      CalFilter.const_set('CGI', create_cgi_instance) unless CalFilter.const_defined?('CGI')
    end
    
    def finish
      CGI.out('text/calendar; charset=utf-8'){ output_stream.string }
    end
  end

  def self.make_cgi_wrapper
    CGIWrapper.new(StringIO.new)
  end
  
  CGIWRAPPER = make_cgi_wrapper
  
end

at_exit do
  CalFilter::CGIWRAPPER.finish
end
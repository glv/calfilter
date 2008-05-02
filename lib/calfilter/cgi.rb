require 'calfilter'
require 'cgi'
require 'stringio'

module CalFilter
  def self.make_cgi
    CGIWrapper.new(StringIO.new)
  end
  
  class CGIWrapper
    def initialize(output_stream)
      set_cgi_constant(create_cgi_instance)
      CalFilter.output_stream = @output_stream = output_stream
    end
    
    def create_cgi_instance
      if CalFilter.respond_to?(:mock_cgi_instance)
        CalFilter.mock_cgi_instance
      else
        CGI.new
      end
    end
    
    def set_cgi_constant(cgi)
      CalFilter.const_set('CGI', cgi) unless CalFilter.const_defined?('CGI')
    end
    
    def finish
      CGI.out('text/calendar; charset=utf-8'){ @output_stream.string }
    end
  end

  CGIWRAPPER = make_cgi
  
end

at_exit do
  CalFilter::CGIWRAPPER.finish
end
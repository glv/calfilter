require 'calfilter'
require 'cgi'
require 'stringio'

module CalFilter
  def self.make_cgi
    CFCGI.new(StringIO.new)
  end
  
  CGI = make_cgi unless const_defined?('CGI')
  
  class CFCGI < ::CGI
    def initialize(output_stream)
      super
      CalFilter.output_stream = @output_stream = output_stream
    end
    
    def finish
      out('text/calendar; charset=utf-8'){ @output_stream.string }
    end
  end
end

at_exit do
  CalFilter::CGI.finish
end
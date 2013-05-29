#!/usr/bin/env ruby

# Would be accessed like this:
# http://example.com/cgi_bin/example.rb?http://example.com/unfiltered_calendar.ics

require 'rubygems'
gem 'calfilter'
require 'calfilter'
require 'calfilter/cgi'

filter_calendars(CalFilter::CGI.query_string) do |cal|
  cal.keep(:events) # drop todos, journals, etc.
  
  cal.filter_events do |evt|
    evt.keep if evt.dtstart >= Date.today # ignore stuff in the past
  end
end

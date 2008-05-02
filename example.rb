#!/usr/bin/env ruby

require 'rubygems'
gem 'calfilter'
require 'calfilter'
require 'calfilter/cgi'

filter_calendars_at(CalFilter::CGI.query_string}) do |cal|
  cal.keep(:events) # drop todos, journals, etc.
  
  cal.filter_events do |evt|
    evt.keep if evt.dtstart >= Date.today # ignore stuff in the past
  end
end

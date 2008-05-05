= calfilter

* http://opensource.thinkrelevance.com/wiki/calfilter

== DESCRIPTION:

calfilter is a small library to assist in writing filtering
programs for icalendar files or streams.  It can be used for
various purposes, including:

* removing items from icalendar feeds that are not interesting to you
* removing private information from your own calendar before publishing it to others
* reformatting a provided calendar to highlight particular information

A calfilter script does most of its work using the filter_calendars[link:files/lib/calfilter_rb.html] method.

== FEATURES:

* require '{calfilter/tripit}[link:files/lib/calfilter/tripit_rb.html]' to add some methods specific to
  tripit.com calendar feeds.

* require '{calfilter/cgi}[link:files/lib/calfilter/cgi_rb.html]' to automatically turn your filter into
  a CGI script.  The CGI object is available as <tt>CalFilter::CGI</tt>.

== SYNOPSIS:

  require 'calfilter'

  cals = filter_calendars('some_url') do |cal|
      cal.keep(:events)  # not journals, todos, or freebusys
    
      cal.filter_events do |evt|
          # Remove events I've marked private
          evt.remove if evt.description =~ /PRIVATE/
          # Don't reveal phone numbers of my contacts
          evt.description.sub! /\d{3}-\d{4}/, '###-####'
      end
  end

== REQUIREMENTS:

calfilter depends on the icalendar gem.

== INSTALL:

sudo gem install calfilter

== AUTHOR

Glenn Vanderburg <glenn@thinkrelevance.com>

== LICENSE:

(The MIT License)

Copyright (c) 2008 Relevance, Inc.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

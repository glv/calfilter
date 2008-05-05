# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/calfilter.rb'

class Hoe
  def extra_deps
    @extra_deps.reject do |x|
      Array(x).first == 'hoe'
    end
  end
end

# Class structure isn't complex enough to make diagrams worthwhile.
ENV['NODOT'] = "true"

Hoe.new('calfilter', CalFilter::VERSION) do |p|
  p.rubyforge_name = 'thinkrelevance'
  p.developer('Glenn Vanderburg', 'glenn@thinkrelevance.com')
  p.extra_deps = %w{icalendar}
end

# vim: syntax=Ruby

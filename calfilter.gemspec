# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "calfilter/version"

Gem::Specification.new do |s|
  s.name        = "calfilter"
  s.version     = CalFilter::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Glenn Vanderburg"]
  s.email       = ["glv@vanderburg.org"]
  s.homepage    = "http://github.com/glv/calfilter"
  s.summary     = %q{Filter icalendar files or streams}
  s.description = %q{calfilter is a small library to assist in writing filtering
  programs for icalendar files or streams.}

  s.rubyforge_project = "calfilter"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
#  s.required_ruby_version = '>= 1.9.2'

  add_runtime_dependency = if s.respond_to?(:specification_version) && Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
                             :add_runtime_dependency
                           else
                             :add_dependency
                           end
  s.send(add_runtime_dependency, 'icalendar')
  
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
end

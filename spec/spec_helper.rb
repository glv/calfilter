require 'rspec/core'

require 'calfilter'

Dir['./spec/support/**/*.rb'].map {|f| require f}

def in_editor?
  ENV.has_key?('TM_MODE') || ENV.has_key?('EMACS') || ENV.has_key?('VIM')
end

RSpec.configure do |c|
  c.color_enabled = !in_editor?
  c.filter_run :focus => true
  c.mock_with :mocha
  c.run_all_when_everything_filtered = true
  c.add_formatter :progress
  c.add_formatter :documentation, 'rspec.txt'
end

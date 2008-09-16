require 'rubygems'
require 'test/spec'
require 'mocha'

require 'calfilter'

describe "filtering calendars" do
  it "should fetch urls and parse them" do
    url = 'http://example.com/'
    ics = 'ics data'
    self.expects(:open).with('http://example.com/', 'r').returns(ics)
    Icalendar.expects(:parse).with(ics).returns([])
    filter_calendars("http://example.com/")
  end
  
  it "should parse ics data" do
    ics = %{
      
      BEGIN:VCALENDAR
    }
    Icalendar.expects(:parse).with(ics).returns([])
    filter_calendars(ics)
  end
  
  it "should pass things straight through" do
    expected_cals = %w{1 2 3}
    actual_cals = filter_calendars(expected_cals.dup)
    assert_equal expected_cals.size, actual_cals.size
  end
  
  it "should delete a calendar when told" do
    cals = filter_calendars(%w{1 2 3}){|cal| cal.remove if cal.__delegate__ == "2"}
    assert_equal %w{1 3}, cals
  end
  
  it "should keep a calendar when told" do
    cals = filter_calendars(%w{1 2 3}){|cal| cal.keep if cal.__delegate__ == "2"}
    assert_equal %w{2}, cals
  end
  
  it "should delete parts of a calendar when told" do
    cals = filter_calendars(%w{1 2 3}) do |cal| 
      events = mock(:clear => nil)
      cal.__delegate__.stubs(:events).returns(events)
      cal.remove(:events)
    end
  end
  
  it "should keep parts of a calendar when told" do
    cals = filter_calendars(%w{1 2 3}) do |cal| 
      events = mock(:clear => nil)
      cal.__delegate__.stubs(:events).returns(events)
      cal.keep(:freebusys, :journals, :todos)
    end
  end
  
  it "should complain if we both keep and remove a calendar" do
    assert_raise(CalFilter::FilterError) do
      cals = filter_calendars(%w{1}){|cal| cal.keep; cal.remove}
    end
  end
  
  it "should complain if we keep one calendar and remove another" do
    assert_raises(CalFilter::FilterError) do
      cals = filter_calendars(%w{1 2 3}) do |cal|
        case cal.__delegate__
        when "1": cal.keep;
        when "2": cal.remove;
        end
      end
    end
  end
  
  it "should delegate unknown methods to the Calendar objects" do
    results = []
    cals = filter_calendars(["a", "aa"]){|cal| results << (cal.size == 1)}
    assert_equal [true, false], results
  end
    
end

describe "filtering resources" do
  before do
    @cal = Icalendar::Calendar.new
    @cal.event do
      dtstart     Date.new(2005, 04, 29)
      dtend       Date.new(2005, 04, 28)
      summary     "Meeting with the man."
      description "Have a long lunch meeting and decide nothing..."
      klass       "PRIVATE"
    end
    @cal.event do
      dtstart     Date.new(2006, 04, 29)
      dtend       Date.new(2005, 04, 28)
      summary     "Project review"
      description "Find a bunch of stuff to complain about and get complaining." 
      klass       "PUBLIC"
    end
  end
  
  xit "should leave resources alone if no block specified" do
    filter_calendars([@cal]) do |cal|
      cal.__delegate__.expects(:events).returns(@cal.events)
      cal.filter_events
    end
  end
  
  xit "should delete a resource when told"
  #@calw = CalFilter.wrap_resource(@cal.events, 'events')
  
  xit "should keep a resource when told" 
  
  xit "should complain if we both keep and remove a resource"
  
  xit "should complain if we keep one resource and remove another"
  
  xit "should delegate unknown methods to the resource objects"
  
end

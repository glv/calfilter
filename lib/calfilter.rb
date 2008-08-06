$:.unshift(File.dirname(__FILE__))

%w{rubygems icalendar date open-uri}.each{|l| require l}
%w{datetime icalendar time}.each{|l| require "calfilter/#{l}_extensions"}

module CalFilter
  VERSION = '1.1.3'
  
  # The output stream for filtered icalendar output.
  # If this is not nil, filter_calendars will automatically
  # write the filtered calendars to this stream in 
  # icalendar format.
  def self.output_stream
    @output_stream
  end
  
  # Sets output_stream.
  def self.output_stream=(stream)
    @output_stream = stream
  end
  
  class FilterError < RuntimeError
  end

  # A filtering wrapper for an 
  # Icalendar[http://icalendar.rubyforge.org/] 
  # resource object.  The wrapped object will be one of:
  #
  # * {Icalendar::Event}[http://icalendar.rubyforge.org/classes/Icalendar/Event.html]
  # * {Icalendar::Freebusy}[http://icalendar.rubyforge.org/classes/Icalendar/Freebusy.html]
  # * {Icalendar::Journal}[http://icalendar.rubyforge.org/classes/Icalendar/Journal.html]
  # * {Icalendar::Todo}[http://icalendar.rubyforge.org/classes/Icalendar/Todo.html]
  #
  # All unrecognized methods are delegated to the underlying
  # resource object, so methods such as #description and #summary
  # work as expected.  (The resource object can be accessed directly
  # using the #\__delegate__ method.)
  #
  # In addition to delegating to the resource, ResourceWrapper objects
  # provide a few additional methods: 
  # 
  # * #\_\_delegate__
  # * #keep
  # * #remove
  class ResourceWrapper
    def initialize(delegate, kind)  # :nodoc:
      @delegate = delegate
      @kind = kind
    end
    
    # Provides access to the underlying resource being wrapped.
    def __delegate__
      @delegate
    end
    
    def __action__    # :nodoc:
      @keep_or_remove || :default
    end
    
    def __kind__      # :nodoc:
      @kind
    end

    # Marks this resource for removal from the calendar.
    # For a particular kind of resource (e.g., events, todos,
    # journals) in a given calendar, you can call either #remove
    # or #keep on some of the resources, but not both.
    def remove
      __flag__ :remove
    end
    
    # Marks this resource to be kept in the calendar.  
    # If this is called on some resources, all others in the
    # collection will be removed.
    # For a particular kind of resource (e.g., events, todos,
    # journals) in a given calendar, you can call either #remove
    # or #keep on some of the resources, but not both.
    def keep
      __flag__ :keep
    end
    
    def method_missing(symbol, *args, &block)     # :nodoc:
      __delegate__.send(symbol, *args, &block)
    end

    protected
    
    def __flag__(sym)                             # :nodoc:
      other_sym = (sym == :keep ? :remove : :keep)
      raise FilterError, "Cannot both keep and remove the same #{@kind}", __caller__ if @keep_or_remove == other_sym
      @keep_or_remove = sym
      throw :bailout if sym == :remove
    end
    
    def __caller__                                # :nodoc:
      f = __FILE__
      stack = caller
      stack.each_with_index do |s, i|
        return stack[i..-1] unless s =~ Regexp.new("^#{Regexp.escape(f)}:")
      end
    end
    
  end

  # A filtering wrapper for an 
  # {Icalendar::Calendar}[http://icalendar.rubyforge.org/classes/Icalendar/Calendar.html] 
  # object.
  #
  # All unrecognized methods are delegated to the underlying
  # Calendar object, so methods such as #events and find_event
  # work as expected.  (The Calendar object can be accessed directly
  # using the #\_\_delegate__ method.)
  #
  # In addition to delegating to the Calendar, CalendarWrapper objects
  # provide a few additional methods: 
  # 
  # * #\_\_delegate__
  # * #keep
  # * #remove
  # * #filter_events
  # * #filter_freebusys
  # * #filter_journals
  # * #filter_todos
  #
  # === Filtering Resource Collections
  #
  # If you want to remove one or more of a calendar's resource collections
  # in their entirety, use #remove (or #keep).  
  # But you can also filter the collections themselves:
  #
  # * <b>filter_events</b> <em>{|event| ... }</em>
  # * <b>filter_freebusys</b> <em>{|freebusy| ... }</em>
  # * <b>filter_journals</b> <em>{|journal| ... }</em>
  # * <b>filter_todos</b> <em>{|todo| ... }</em>
  #
  # Each of these methods iterates over all of the elements of 
  # the named resource collection, allowing the individual resources
  # to be modified or removed.  See ResourceWrapper for the methods
  # available for working with individual resource instances.
  class CalendarWrapper < ResourceWrapper
    RESOURCE_TYPES = %w{events freebusys journals todos}
    
    def initialize(calendar)   # :nodoc:
      super(calendar, 'calendar')
    end
    
    # :call-seq:
    #   remove
    #   remove(collection_symbol, [collection_symbol, ...])
    #
    # Marks this calendar (or collection of resources in the calendar) for removal.
    #
    # If called with no arguments, removes the entire calendar.  
    #
    # Any arguments must be one of <tt>:events</tt>, <tt>:freebusys</tt>, 
    # <tt>:journals</tt>, or <tt>:todos</tt>, and 
    # the named resource collections will be removed from this calendar.
    #
    # For a given calendar or resource collection, you can call either #remove
    # or #keep, but not both.
    def remove(*args)
      if args.empty?
        super
      else
        __remove_elements__ :remove, args
      end
    end
    
    # :call-seq:
    #   keep
    #   keep(collection_symbol, [collection_symbol, ...])
    #
    # Marks this calendar (or collection of resources in the calendar) to be kept.
    #
    # If called with no arguments, keeps the entire calendar; any calendars
    # not kept will be removed.
    #
    # Any arguments must be one of <tt>:events</tt>, <tt>:freebusys</tt>, 
    # <tt>:journals</tt>, or <tt>:todos</tt>, and 
    # the named resource collections will be kept in this calendar, and
    # all resource collections not kept will be removed.
    #
    # For a given calendar or resource collection, you can call either #remove
    # or #keep, but not both.
    def keep(*args)
      if args.empty?
        super
      else
        __remove_elements__ :keep, RESOURCE_TYPES.map{|t|t.to_sym} - args
      end
    end
    
    def method_missing(symbol, *args, &block)  # :nodoc:
      if symbol.to_s =~ /^filter_(.*)$/ && RESOURCE_TYPES.include?($1)
        __filter_resource__($1, *args, &block)
      else
        super(symbol, *args, &block)
      end
    end
    
    private
    
    def __remove_elements__(sym, to_remove)
      other_sym = (sym == :keep ? :remove : :keep)
      raise FilterError, "Cannot call both keep and remove for elements in the same calendar", __caller__ if @keep_or_remove_elements == other_sym
      @keep_or_remove_elements = sym
      to_remove.each{|sym| __delegate__.send(sym).clear}
    end
      
    def __filter_resource__(resource_type)
      resources = __delegate__.send(resource_type.to_sym)
      return resources unless block_given?
      actions = resources.map do |res| 
        wrapper = CalFilter.wrap_resource(res, resource_type)
        catch(:bailout) do
          yield wrapper
        end
        wrapper.__action__
      end
      __delegate__.send("#{resource_type}=".to_sym, CalFilter::keep_or_delete_items(resources, resource_type, actions))
    end
    
  end
  
  def self.wrap_calendar(cal)   # :nodoc:
    CalendarWrapper.new(cal)
  end
  
  def self.wrap_resource(res, plural_resource_type)  # :nodoc:
    # This works with the particular resource names in Icalendar:
    singular_resource_type = plural_resource_type.sub(/s$/, '')
    ResourceWrapper.new(res, singular_resource_type)
  end
  
  def self.keep_or_delete_items(items, type, actions)   # :nodoc:
    if actions.include?(:keep) && actions.include?(:remove)
      raise CalFilter::FilterError, "Cannot both keep and remove #{type} in the same group.", caller(2)
    end
    keep_action = (actions.include?(:keep) ? :keep : :default)
    kept_items = []
    items.each_with_index{|item, i| kept_items << item if actions[i] == keep_action}
    kept_items
  end
  
end

# Filters the calendars found at sources.
#
# The sources can be 
#
# * {Icalendar::Calendar}[http://icalendar.rubyforge.org/classes/Icalendar/Calendar.html]
#   objects, 
# * arrays of those objects (because Icalendar.parse returns arrays
#   of calendars),
# * URLs pointing to iCalendar[http://en.wikipedia.org/wiki/ICalendar] streams, or
# * strings containing iCalendar[http://en.wikipedia.org/wiki/ICalendar] streams.
#
# The sources are resolved/fetched/parsed into Icalendar::Calendar
# objects, and passed into the supplied block one by one (as
# CalendarWrapper objects).  The block can filter the calendars,
# choosing to remove entire calendars or classes of calendar resources,
# and/or simply modifying those resources as desired.  Each calendar object
# has a #source method that contains associated source parameter from the
# #filter_calendars call (so that you can recognize different calendars and
# handle them in distinct ways).
#
# The method returns an array of Calendar objects representing the filtered
# result.  If CalFilter::output_stream is not nil, the method will also write
# the filtered result (as an iCalendar stream) to that output stream before
# returning.
def filter_calendars(*sources, &block)
  cals = convert_to_icalendars(sources)
  return cals unless block_given?
  actions = cals.map do |cal| 
    wrapper = CalFilter.wrap_calendar(cal)
    catch(:bailout) do
      yield wrapper
    end
    wrapper.__action__
  end
  new_cals = CalFilter::keep_or_delete_items(cals, 'calendars', actions)
  os = CalFilter.output_stream
  unless os.nil?
    new_cals.each{|cal| os.puts cal.to_ical}
  end
  new_cals
end

def convert_to_icalendars(sources)  # :nodoc:
  sources.inject([]){|accum, source| accum += convert_to_icalendar(source)}
end

def convert_to_icalendar(source)  # :nodoc:
  icalendars = case source
               when Icalendar::Calendar
                 [source]
               when Array
                 source
               when /^\s*BEGIN:VCALENDAR/m
                 Icalendar.parse(source)
               else
                 Icalendar.parse(open(source, 'r'))
               end
  attach_source_to_icalendars(source, icalendars)
  icalendars
end

def attach_source_to_icalendars(source, icalendars)             
  icalendars.each do |icalendar|
    class <<icalendar
      attr_reader :source
    end
    icalendar.instance_variable_set("@source", source)
  end
  
  icalendars
end

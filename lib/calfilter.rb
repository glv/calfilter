%w{rubygems icalendar date open-uri}.each{|l| require l}

module CalFilter
  VERSION = '1.1.2'
  
  def self.output_stream
    @output_stream
  end
  
  def self.output_stream=(stream)
    @output_stream = stream
  end
  
  class FilterError < RuntimeError
  end

  class ResourceWrapper
    def initialize(delegate, kind)
      @delegate = delegate
      @kind = kind
    end
    
    def __delegate__
      @delegate
    end
    
    def __action__
      @keep_or_remove || :default
    end
    
    def __kind__
      @kind
    end

    def remove
      __flag__ :remove
    end
    
    def keep
      __flag__ :keep
    end
    
    def method_missing(symbol, *args, &block)
      __delegate__.send(symbol, *args, &block)
    end

    protected
    
    def __flag__(sym)
      other_sym = (sym == :keep ? :remove : :keep)
      raise FilterError, "Cannot both keep and remove the same #{@kind}", __caller__ if @keep_or_remove == other_sym
      @keep_or_remove = sym
      throw :bailout if sym == :remove
    end
    
    def __caller__
      f = __FILE__
      stack = caller
      stack.each_with_index do |s, i|
        return stack[i..-1] unless s =~ Regexp.new("^#{Regexp.escape(f)}:")
      end
    end
    
  end

  class CalendarWrapper < ResourceWrapper
    RESOURCE_TYPES = %w{events freebusys journals todos}
    
    def initialize(calendar)
      super(calendar, 'calendar')
    end
    
    def remove(*args)
      if args.empty?
        super
      else
        __remove_elements__ :remove, args
      end
    end
    
    def keep(*args)
      if args.empty?
        super
      else
        __remove_elements__ :keep, RESOURCE_TYPES.map{|t|t.to_sym} - args
      end
    end
    
    def method_missing(symbol, *args, &block)
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
  
  def self.wrap_calendar(cal)
    CalendarWrapper.new(cal)
  end
  
  def self.wrap_resource(res, plural_resource_type)
    # This works with the particular resource names in Icalendar:
    singular_resource_type = plural_resource_type.sub(/s$/, '')
    ResourceWrapper.new(res, singular_resource_type)
  end
  
  def self.keep_or_delete_items(items, type, actions)
    if actions.include?(:keep) && actions.include?(:remove)
      raise CalFilter::FilterError, "Cannot both keep and remove #{type} in the same group.", caller(2)
    end
    keep_action = (actions.include?(:keep) ? :keep : :default)
    kept_items = []
    items.each_with_index{|item, i| kept_items << item if actions[i] == keep_action}
    kept_items
  end
  
end

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

def convert_to_icalendars(sources)
  sources.inject([]){|accum, source| accum += convert_to_icalendar(source)}
end

def convert_to_icalendar(source)
  case source
  when Icalendar::Calendar
    [source]
  when Array
    source
  when /^\s*BEGIN:VCALENDAR/m
    Icalendar.parse(source)
  else
    Icalendar.parse(open(source, 'r'))
  end
end

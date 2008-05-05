# Mixes methods into CalFilter::ResourceWrapper that help when 
# dealing with calendars from TripIt[http://tripit.com/].  Just
# require this file at the top of a calfilter script to gain the
# extra functionality.

require 'calfilter'

module CalFilter
  module TripIt
    # The keys are the $1 strings from description =~ /^\[(.*?)\]/m
    EVENT_TYPES = {
      nil          => :trip,
      'Activity'   => :activity,
      'Article'    => :article,
      'Car Rental' => :car,
      'Cruise'     => :cruise,
      'Directions' => :directions,
      'Flight'     => :flight,
      'Hotel'      => :hotel,
      'Map'        => :map,
      'Meeting'    => :meeting,
      'Note'       => :note,
      'Rail'       => :rail,
      'Restaurant' => :restaurant
    }
    
    # :call-seq:
    #   tripit_type => tripit_type_symbol
    #   tripit_type(tripit_type_symbol, ...) => true or false
    #
    # Investigates the type of an event, based on <tt>[<em>Type</em>]</tt> strings in the descriptions used by Trip<b></b>It.
    #
    # TripIt[http://tripit.com/] uses <tt>[<em>Event Type</em>]</tt> strings in its
    # event descriptions to signal what kind of event it is.  The known types are the
    # keys used in EVENT_TYPES.
    # 
    # This method facilitates querying an event to learn its Trip<b></b>It event type.
    #
    # When called with no arguments, the method will return an event type
    # symbol (one of the values from EVENT_TYPES) to indicate the type of 
    # event, or :unknown if an unknown type is encountered (or if the target is
    # some other kind of Icalendar resource, such as a todo).
    #
    # When called with argumetns, those arguments must be event type symbols,
    # and the method will return true if the event is one of those types, and
    # false otherwise (or if the target is not an event).
    def tripit_type(*args)
      if args.empty?
        return :unknown unless __kind__ == 'event'
        description =~ /^\[(.+?)\]/m
        TripIt::EVENT_TYPES[$1] || :unknown
      else
        return false unless __kind__ == 'event'
        args.include?(tripit_type)
      end
    end
  end

  class ResourceWrapper
    include TripIt
  end
end
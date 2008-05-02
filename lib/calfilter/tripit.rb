require 'calfilter'

module CalFilter
  module TripIt
    EVENT_TYPES = {
      # The keys are the $1 strings from description =~ /^\[(.*?)\]/m
      nil          => :trip,
      'Flight'     => :flight,
      'Car Rental' => :car,
      'Hotel'      => :hotel,
      'Directions' => :directions,
      'Activity'   => :activity
    }
    
    def tripit_type(*args)
      return :unknown unless __kind__ == 'event'
      if args.empty?
          description =~ /^\[(.+?)\]/m
          TripIt::EVENT_TYPES[$1] || :unknown
        else
          args.include?(tripit_type)
        end
      end
    end

  end
  
  class ResourceWrapper
    include TripIt
  end
end
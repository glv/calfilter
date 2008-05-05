class Icalendar::Parser
  def parse_datetime_with_date_check(name, params, value)
    if /\d{8}T/ =~ value
      dt = parse_datetime_without_date_check(name, params, value)
      dt.utc = true if /Z/ =~ value
      dt
    else
      begin
        Date.parse(value)
      rescue Exception
        value
      end
    end
  end
  
  alias :parse_datetime_without_date_check :parse_datetime
  alias :parse_datetime :parse_datetime_with_date_check
end

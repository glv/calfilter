class DateTime
  attr_writer :utc
  
  def utc?
    @utc
  end
  
  def to_ical(unused_utc = false)
    strftime('%Y%m%dT%H%M%S') + (utc? ? 'Z' : '')
  end
  
end
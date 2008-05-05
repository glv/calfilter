class Time  # :nodoc: all
  attr_writer :utc
  
  def utc?
    @utc
  end
  
  def to_ical(unused_utc = false)
    strftime('%H%M%S') + (utc? ? 'Z' : '')
  end
  
end
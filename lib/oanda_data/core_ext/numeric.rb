class Numeric
  def seconds
    self
  end
  alias :second :seconds

  def minutes
    self * 60
  end
  alias :minute :minutes

  def hours
    self * 3_600
  end
  alias :hour :hours

  def days
    self * 86_400
  end
  alias :day :days
end

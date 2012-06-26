class Fixnum
  def round_to_nearest(decimal)
    return decimal if self == 0
    return self if self % decimal == 0
    self + decimal - (self % decimal)
  end
end
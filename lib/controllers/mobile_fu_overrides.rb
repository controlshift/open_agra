module MobileFuOverrides
  def is_mobile_device?
    return false if is_device?('ipad')
    super
  end
end
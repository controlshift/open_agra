module FullName
  def full_name(masked = false)
    if first_name.present? && last_name.present?
      masked ? "#{first_name} #{last_name[0]}." : "#{first_name} #{last_name}"
    elsif first_name.present?
      first_name
    elsif last_name.present?
      last_name
    else
      "Not provided"
    end
  end

  def first_name_or_friend
    first_name.blank? ? I18n.t('signature.friend') : first_name
  end

  def full_name_with_mask
    full_name true
  end
end
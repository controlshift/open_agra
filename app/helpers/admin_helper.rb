module AdminHelper
  def org_admin?
    controller_path.starts_with?('org')
  end

  def parent_name_punctuation(current_organisation)
    parent_name = current_organisation.parent_name
    parent_name.concat(".") if !parent_name.blank? && !parent_name.end_with?('!', '.')
    parent_name
  end
end

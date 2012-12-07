module AdminHelper
  def org_admin?
    controller_path.starts_with?('org')
  end

  def parent_name_punctuation(current_organisation)
    parent_name = current_organisation.parent_name
    parent_name.concat(".") if need_punctuation?(parent_name)
    parent_name
  end

  def need_punctuation?(parent_name)
    parent_name.present? && !parent_name.end_with?('!', '.')
  end
end

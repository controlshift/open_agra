module ApplicationHelper
  include OrganisationHelpers
  include AdminHelper

  def title(page_title, options = {})
    content_for(:title, page_title.to_s + " | " + current_organisation.name)
    content_tag(:h1, page_title, options)
  end

  def cf(slug)
    Content.content_for(slug, current_organisation)
  end

  def sortable(column, title = nil)
    column_name = column.to_s
    title ||= column_name.titleize
    css_class = column_name == list.sort_column ? "current #{list.sort_direction}" : nil
    direction = column_name == list.sort_column && list.sort_direction == "desc" ? "asc" : "desc"
    link_to title, {sort: column_name, direction: direction}, {class: css_class}
  end

  def in_mobile_view?
    false
  end

  def ask_for_location?
    current_organisation.requires_location_for_campaign? || @effort && @effort.ask_for_location?
  end

  def join_label
    if current_organisation.join_label.blank?
      "Join #{current_organisation.combined_name}"
    else
      current_organisation.join_label
    end
  end

  private
  def list
    @list
  end
end

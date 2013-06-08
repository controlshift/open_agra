module ApplicationHelper
  include OrganisationHelpers
  include AdminHelper
  include SignaturesHelper

  def title(page_title, options = {})
    content_for(:title, page_title.to_s + " | " + current_organisation.name)
    content_tag(:h1, page_title, options)
  end

  def manage_title(page_title, options = {})
    content_for(:title, page_title.to_s + " | " + current_organisation.name)
    output = render partial: 'petitions/manage/manage_title', locals: {kind: options[:kind]}
    output += content_tag(:h2, page_title, options)
    output
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
    current_organisation.requires_location_for_campaign? || effort_requires_location_for_campaign?
  end

  def can_share_with_friends_on_facebook?
    session[:facebook_access_token].present?
  end

  def join_label
    if current_organisation.join_label.blank?
      "Join #{current_organisation.combined_name}"
    else
      current_organisation.join_label
    end
  end

  def image_content(options={})
    params = {:style => :hero, content_class: 'petition-image', image_field: 'image'}.merge(options)
    entity = params[:entity]
    style = params[:style]
    content_class = params[:content_class]
    image = entity.send(:"#{params[:image_field]}")
    content_tag(:div, class: content_class) do
      unless entity.errors.any? || entity.send("#{params[:image_field]}_file_name").blank?
        image_tag(image.url(style), title: (entity.respond_to?(:title) ? entity.title : 'Picture'), alt: (entity.respond_to?(:title) ? entity.title : 'Picture'))
      else
        placeholder_image(style)
      end
    end
  end

  def placeholder_image(style = 'hero')
    if current_organisation.placeholder.present?
      image_tag(current_organisation.placeholder)
    else
      image_tag("image-placeholder-#{style}.png")
    end
  end

  def display_profile_image(options={})
    params = {:style => :icon, content_class: 'profile-image', image_field: 'image'}.merge(options)
    entity = params[:entity]
    style = params[:style]
    content_class = params[:content_class]
    unless entity.errors.any? || entity.send("#{params[:image_field]}_file_name").blank?
        image_tag entity.send("#{params[:image_field]}").url(style), alt: (entity.respond_to?(:title) ? entity.title : 'Picture'), class: content_class   
    else 
      if entity.facebook_id.present?
        image_tag "http://graph.facebook.com/#{entity.facebook_id}/picture", class: content_class        
      end
    end     
  end

  def image_url(source)
    abs_path = image_path(source)
    unless abs_path =~ /^http/
      abs_path = "#{request.protocol}#{request.host_with_port}#{abs_path}"
    end
    abs_path
  end

  private
  def list
    @list
  end

  def effort_requires_location_for_campaign?
    @petition && @petition.effort && @petition.effort.ask_for_location?
  end
end

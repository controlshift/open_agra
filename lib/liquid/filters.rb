module UrlFilters
  include Rails.application.routes.url_helpers
  include ActionDispatch::Routing::UrlFor
  include ActionView::Helpers::TagHelper

  def link_to_petition(link_text, petition)
    link_for(link_text, petition_url(petition))
  end

  def link_to_manage_petition(link_text, petition)
    link_for(link_text, petition_manage_url(petition))
  end
  
  def link_to_launch_petition(link_text, petition)
    link_for(link_text, launch_petition_url(petition))
  end
  
  def link_to_new_petition_email(link_text, petition)
    link_for(link_text, new_petition_email_url(petition))
  end
  
  def link_to_deliver_petition_manage(link_text, petition)
    link_for(link_text, deliver_petition_manage_url(petition))
  end

  def link_for(link_text, url, blank = false)
    link_text = url if link_text.blank?
    if blank
      content_tag :a, link_text, { href: url, title: link_text, target: "_blank" }
    else
      content_tag :a, link_text, { href: url, title: link_text }
    end
  end

private
  def find_organisation
    if @context['organisation'] && @context['organisation'].respond_to?(:host)
      @context['organisation']
    elsif @context['petition'] && @context['petition'].respond_to?(:organisation) && @context['petition'].organisation.respond_to?(:host)
      @context['petition'].organisation
    else
      nil
    end

  end

  def default_url_options
    organisation = find_organisation

    if organisation.present?
      {:host => organisation.host}
    else
      {}
    end
  end

  def is_haml?
    return false
  end
end



Liquid::Template.register_filter(UrlFilters)
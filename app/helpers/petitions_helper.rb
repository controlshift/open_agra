module PetitionsHelper
  def share_email_body_text(petition)

    name = current_user ? current_user.first_name : ""
    verb = (petition.user == current_user) ? "created" : "signed"

    render :partial => 'petitions/view/email_body_template', :locals => {
      :petition => petition,
      :name => name,
      :verb => verb
    }
  end

  def input_field(form, field, label, help, html_options = {})
    if @effort && field.in?([:who, :what, :why, :title])
      effort_field_label = "#{field}_label".intern
      effort_field_help  = "#{field}_help".intern
      effort_field_default  = "#{field}_default".intern

      label = @effort.send(effort_field_label) if @effort.send(effort_field_label).present?
      help  = @effort.send(effort_field_help)  if @effort.send(effort_field_help).present?
      if @effort.send(effort_field_default).present? && @petition.send(field).blank?
        default = @effort.send(effort_field_default)
      else
        default = @petition.send(field)
      end
    else
      default =  @petition.send(field)
    end

    form.input field, label: label, input_html: { value: default, class: 'span7', rel: "popover", 'data-title'=> "#{label}", 'data-content' => "#{help}" }.update(html_options)
  end
  
  def petition_image(petition, style=:hero)
    content_tag(:div, class: "petition-image") do
      unless petition.image_file_name.blank?
        image_tag(petition.image.url(style), title: petition.title, alt: petition.title)
      else
        image_tag("petition-image-placeholder-#{style}.png")
      end
    end
  end

  def petition_image_for_share(petition)
    unless petition.image_file_name.blank?
      @petition.image.url(:form)
    else
      request.protocol.to_s +  request.host_with_port.to_s +
          "/assets/organisations/#{current_organisation.slug}/logo_share.png"
    end
  end

  def contact_admin(petition)
    mailto = "mailto:#{petition.organisation.contact_email}"
    mailto << "?subject=Campaigner message RE: #{petition.title}"
    mailto << "&body=Petition Title: #{petition.title}%0APetition URL: #{petition_url(petition)}%0AUser:#{current_user.email}%0A"
    mailto << "--- The following message is with regards to the above petition: ---"
    mailto
  end

  def petition_class(petition)
    if petition.cancelled?
      "list-item-cancelled"
    elsif !petition.launched?
      "list-item-not-launched"
    else
      ""
    end
  end

  def highlighted(elem_id, selected_id)
    elem_id == selected_id ? 'active' : nil
  end

  def twitter_share_href(petition)
    href =  "https://twitter.com/intent/tweet?"
    href << "url=#{petition_url(petition)}"
    if petition.organisation.twitter_account_name.present?
      href << "&via=#{petition.organisation.twitter_account_name}"
      href << "&related=#{petition.organisation.twitter_account_name}:#{CGI::escape('For more important campaigns')}"
    end
    href << "&text=#{CGI::escape_html(cf('twitter_share_text'))}"
    href
  end

  def facebook_share_href(petition)
    "http://www.facebook.com/sharer.php?u=#{CGI::escape(petition_url(petition, time: petition.updated_at.to_i))}"
  end
end

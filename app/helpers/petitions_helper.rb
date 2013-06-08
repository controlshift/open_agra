module PetitionsHelper
  include InputFieldsHelper

  def share_email_body_text(petition)

    name = current_user ? current_user.first_name : ""
    verb = (petition.user == current_user) ? "created" : "signed"

    render :partial => 'petitions/view/email_body_template', :locals => {
        :petition => petition,
        :name => name,
        :verb => verb
    }
  end

  def input_field_for_petition(form, field, label, help, html_options = {})
    if @effort && field.in?([:who, :what, :why, :title])
      effort_field_label = "#{field}_label".intern
      effort_field_help = "#{field}_help".intern
      effort_field_default = "#{field}_default".intern

      label = @effort.send(effort_field_label) if @effort.send(effort_field_label).present?
      help = @effort.send(effort_field_help) if @effort.send(effort_field_help).present?
      if @effort.send(effort_field_default).present? && @petition.send(field).blank?
        default = @effort.send(effort_field_default)
      end
    end
    input_field_with_popover @petition, form, field, label, help, default, html_options
  end

  def petition_image_for_share(share)
    if share.image_file_name.blank?
      image_url('fb-no-share-image.png')
    else
      share.image.url(:form)
    end
  end

  def contact_admin(petition)
    mailto = t('helpers.petition.contact_admin.mailto', {p_contact_email: petition.organisation.contact_email, petition_title: petition.title, u_email: current_user.email, petition_url: petition_url(petition)})
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
    elem_id == selected_id ? 'manage-tab highlighted' : 'manage-tab'
  end

  def leading_progress(current_progress)
    progresses.inject([]) do |arr, progress|
      arr << progress_tag(progress, current_progress)
    end.join("").html_safe
  end

  def twitter_share_href(petition)
    href = "https://twitter.com/intent/tweet?"
    href << "url=#{petition_url(petition, source: 'twitter-share-button')}"
    if petition.organisation.twitter_account_name.present?
      href << "&via=#{petition.organisation.twitter_account_name}"
      href << "&related=#{petition.organisation.twitter_account_name}:#{CGI::escape(t('helpers.petition.twitter_share.important'))}"
    end
    href << "&text=#{CGI::escape_html(cf('twitter_share_text'))}"
    href
  end

  def facebook_share_href(petition)
    share = petition.facebook_share
    # undocumented link format: http://www.wealsodocookies.com/posts/generate-a-share-with-facebook-link-that-embed-summary-title-images-but-without-og-data
    href = 'http://www.facebook.com/sharer/sharer.php'
    share_url = CGI::escape(facebook_petition_url(share))
    if respond_to?(:is_mobile_device?) && is_mobile_device?
      href << '?u=' # facebook doesn't read anything else on mobile devices
      href << share_url
    else
      href << '?s=100&p[url]='
      href << CGI::escape(facebook_petition_url(share))
      href << '&p[title]='
      href << CGI::escape(share.title)
      href << '&p[summary]='
      href << CGI::escape(share.description)
      href << '&p[images][0]='
      href << CGI::escape(petition_image_for_share(share))
    end
    href
  end

  def facebook_petition_url(share)
    if share.variant
      petition_facebook_share_variant_url(share.petition, share.variant, {time: share.petition.updated_at.to_i, source: 'facebook-share-button'})
    else
      petition_url(share.petition, time: share.petition.updated_at.to_i, source: 'facebook-share-button')
    end
  end

  def achievements_accordion(title, id, &block)
    completed = @petition.achievements[id].present?

    content_tag(:div, id: "group-#{id}", class: 'accordion-group') do
      concat(content_tag(:div, class: 'accordion-heading') do
        link_to "#collapse-#{id}", class: "accordion-toggle", "data-toggle" => 'collapse', "data-parent" => '#achievements-accordion' do
          concat(image_tag (completed ? "bullet-round-done.png" : "bullet-round-pending.png"), {class: (completed ? "step-completed" : "not-completed")})
          concat(title)
        end
      end)
      concat(content_tag(:div, id: "collapse-#{id}", class: "accordion-body collapse") do
        content_tag(:div, class: 'accordion-inner') do
          concat(capture(&block))
        end
      end)
    end
  end

  def pretty_date_format(date, format="%d/%b/%Y")
    date > 1.week.ago ? distance_of_time_in_words(Time.now, date) + " #{t('ago')}" : date.strftime(format)
  end

  def link_to_leaders(effort, petition)
    return '-' if petition.user.blank?
    link_to(petition.user.full_name, org_effort_leader_path(effort, petition))
  end

  def link_to_edit_user(user)
    return '-' if user.blank?
    edit_path = org_admin? ? edit_org_user_path(user) : edit_admin_user_path(user)
    link_to(user.full_name, edit_path)
  end

  def printable_attribute user, attribute
    user.present? ? user.send(attribute) : "-"
  end

  def load_petition(petition_id)
    Petition.find_by_id(petition_id)
  end

  def google_static_map(options={})
    default_options = {location: Location.new(:latitude => 0, :longitude => 0)}
    options = default_options.merge(options)

    location = options[:location]
    geography = options[:geography]

    if geography
      # Static maps won't take thousands of points, so skip some. Hopefully not the important ones.
      path = geography.summarize_points(75).map(&:shape).map {|p| [p.lat, p.lon].join(',')}.join('|')
      image_tag "http://maps.googleapis.com/maps/api/staticmap?size=#{options[:size]}&path=color:0xF63935|fillcolor:0xF6393533|#{path}&sensor=false".gsub(/\|/, '%7C')
    elsif location
      address = "#{options[:location].latitude},#{options[:location].longitude}"
      image_tag("http://maps.googleapis.com/maps/api/staticmap?size=#{options[:size]}&zoom=#{options[:location].zoom}
               &markers=icon:http://static.controlshiftlabs.com/assets/marker-centered.png%7Cshadow:false%7C#{address}&sensor=false")
    end
  end

  def petition_chevron_for_edit_prompt_effort
    prompt_edit_step_hash = { 1 => ['lead-petition', t('helpers.petition.register')],
                              2 => ['training', t('helpers.petition.training')],
                              3 => ['edit', t('helpers.petition.edit')],
                              4 => ['start', t('helpers.petition.start')] }
    petition_chevron(prompt_edit_step_hash)
  end

  def petition_chevron_for_normal_effort
    step_hash = { 1 => ['lead-petition', t('helpers.petition.register')],
                  2 => ['training', t('helpers.petition.training')],
                  3 => ['start', t('helpers.petition.start')] }
    petition_chevron(step_hash)
  end

  private

  def petition_chevron(step_hash={})
    (step_hash.keys.sort).inject([]) do |arr, i|
      arr << petition_chevron_step(step: i, dom_class: step_hash[i].first, label: step_hash[i].last)
    end.join(separator).html_safe
  end

  def separator
    image_tag(asset_path("bullet-pointer.png"))
  end

  def petition_chevron_step(options={})
    capture_haml do
      haml_tag "span.#{options[:dom_class]}" do
        haml_tag "span.number" do
          haml_concat "#{options[:step]}"
        end
        haml_tag :span do
          haml_concat "#{options[:label]}"
        end
      end
    end
  end

  def progresses
    ['lead', 'training', 'manage', 'share']
  end

  def lead_progress_status(progress, current_progress)
    progresses.index(progress) <= progresses.index(current_progress) ? "accomplished" : "unaccomplished" rescue "unaccomplished"
  end

  def progress_tag(progress, current_progress)
    capture_haml do
      status = lead_progress_status(progress, current_progress)
      haml_tag "span.#{status}.#{progress}-status.status" do
        haml_concat progress
      end
    end
  end

  def sign_partial_cache_key(organisation, petition, source = "", akid="")
    key = "sign_#{organisation.cache_key}_#{petition.cache_key}_#{source}#{akid}"
    if petition.group_id.present?
      "#{key}_#{petition.group.cache_key}"
    else
      key
    end
  end

  def signature_disclaimer(petition)
    if petition.group && petition.group.signature_disclaimer
      petition.group.signature_disclaimer
    else
      current_organisation.signature_disclaimer
    end
  end

end

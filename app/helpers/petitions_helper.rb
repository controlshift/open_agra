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

  def petition_image_for_share(petition)
    unless petition.image_file_name.blank?
      @petition.image.url(:form)
    else
      "#{request.protocol}#{request.host_with_port}/assets/organisations/#{current_organisation.slug}/logo_share.png"
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
    elem_id == selected_id ? 'manage-tab highlighted' : 'manage-tab'
  end

  def leading_progress(current_progress)
    progresses.inject([]) do |arr, progress|
      arr << progress_tag(progress, current_progress)
    end.join("").html_safe
  end

  def twitter_share_href(petition)
    href = "https://twitter.com/intent/tweet?"
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
    date > 1.week.ago ? distance_of_time_in_words(Time.now, date) + " ago" : date.strftime(format)
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

    address = "#{options[:location].latitude},#{options[:location].longitude}"
    image_tag("http://maps.googleapis.com/maps/api/staticmap?size=#{options[:size]}&zoom=#{options[:location].zoom}
               &markers=icon:http://static-targets-showcase.controlshiftlabs.com/assets/marker.png%7Cshadow:false%7C#{address}&sensor=false")
  end

  def petition_chevron_for_edit_prompt_effort
    prompt_edit_step_hash = { 1 => ['lead-petition', 'Register'],
                              2 => ['training', 'Training'],
                              3 => ['edit', 'Edit'],
                              4 => ['start', 'Start'] }
    petition_chevron(prompt_edit_step_hash)
  end

  def petition_chevron_for_normal_effort
    step_hash = { 1 => ['lead-petition', 'Register'],
                  2 => ['training', 'Training'],
                  3 => ['start', 'Start'] }
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

end

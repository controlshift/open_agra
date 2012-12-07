module InputFieldsHelper
  def input_field_with_popover(object, form, field, label, help, value = nil, html_options = {})
    value ||= object.send(field)
    form.input field, label: label, input_html: { value: value, class: 'span7', rel: 'popover',
                                                  'data-title' => "#{label}",
                                                  'data-content' => "#{help}" }.update(html_options)
  end

end
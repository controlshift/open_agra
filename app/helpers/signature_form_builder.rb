class SignatureFormBuilder < SimpleForm::FormBuilder
  include ActionView::Helpers::TagHelper
  
  def first_name
    buffer = String.new
    buffer << self.input(:first_name, label: 'First name', input_html: { validate: { format: false }, class: 'signature-narrow' })
    help_hover(buffer, "Petitions that dont use real names get taken less seriously. Using your real name adds power to the petition and makes it more effective.")
  end
  
  def last_name
    self.input :last_name, label: 'Last name', input_html: { validate: { format: false } }
  end

  def post_code(label)
    self.input :postcode, label: "#{label} <abbr title=\"required\">*</abbr> "
  end

  def tracking_fields
    buffer = String.new
    buffer << self.input(:source, as: :hidden)
    buffer << self.input(:akid,   as: :hidden)
    buffer.html_safe
  end
  
  def email
    self.input :email, label: 'Email', input_html: { type: 'email' , validate: {uniqueness: false }}, hint: ''
  end

  def additional_boolean_field(field_name, field_config)
    buffer = String.new
    builder = Builder::XmlMarkup.new(target: buffer)
    builder.div(class: 'checkbox') do | checkbox |
      checkbox << self.check_box_tag(field_name, 1, false, id: "signature_#{field_name}", name: "signature[#{field_name}]", class: 'boolean')
      checkbox.label(class: "subtle mr10", for: "signature_#{field_name}") do |label|
        label << field_config[:label]
      end
      if field_config[:why].present?
        help_hover(buffer, field_config[:why], 'checkbox-why')
      end
    end
  end

  def additional_field(field, options)
    validation_options = options.delete(:validation_options)
    options[:required] = true if validation_options && validation_options[:presence]
    if options[:kind] == :boolean
      self.additional_boolean_field field, options
    else
      self.input field, options
    end
  end
  
  def phone_number
    buffer = String.new
    buffer << self.input(:phone_number, label: 'Phone Number', input_html: {class: 'signature-narrow'})
    help_hover(buffer, 'Not publicly visible. The creator of this petition may contact you about important moments in this campaign.')
  end
  
  def help_hover(buffer, help_string, klass= 'input-why')
    builder = Builder::XmlMarkup.new(target: buffer)
    builder.div(class: klass) do | why |
      why.a("?", {rel:'popover', 'data-placement'=> 'left', 'data-offset' => 190, 'data-original-title'=>'?', 'data-content'=> help_string })
    end
    ("" + buffer).html_safe
  end
end
module SignaturesHelper
  def additional_field_input(form, field, options)
    validation_options = options.delete(:validation_options)
    options[:required] = true if validation_options && validation_options[:presence]
    form.input field, options
  end

  def should_display_field?(field_config)
    # we store a regular expression in the field definition to determine whether the field should be displayed
    # within certain categories.
    !field_config[:category] || @petition.categories.detect {|c| c.name =~ field_config[:category]}
  end
end
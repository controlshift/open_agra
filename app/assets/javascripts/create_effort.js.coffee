$ ->
  $(":input[type=text]:visible:enabled:first").popover('show')

  $('#effort_effort_type_specific_targets').on 'click', (event) ->
    unless $('#advanced').hasClass("in")
      $('.accordion-toggle').click()

  specific_target_hidden_fields = $('.who_wrapper, #petition-form-tab, .ask-for-location')
  open_ended_hidden_fields = $('.leader-duties-text, .how-this-works-text, .training-text, .training-sidebar-text, .prompt-edit')

  open_ended_hidden_fields.hide()

  $('#effort_effort_type_specific_targets').on 'click', () ->
    specific_target_hidden_fields.hide()
    open_ended_hidden_fields.show()
    $('#petition-text-tab a').click()

  $('#effort_effort_type_open_ended').on 'click', () ->
    specific_target_hidden_fields.show()
    open_ended_hidden_fields.hide()
    clear_blank_error_in_petition_text()
    $('#petition-text-tab a').click()

  if $('#effort_effort_type_specific_targets').attr('checked') == 'checked'
    $('#effort_effort_type_specific_targets').click()

  clear_blank_error_in_petition_text = ->
    $('#petition-text .help-inline').hide()
    $('#petition-text .control-group').removeClass('error')

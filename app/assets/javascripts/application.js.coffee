# This is a manifest file that'll be compiled into including all the files listed below.
# Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
# be included in the compiled file accessible from http://example.com/assets/application
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#= require jquery_ujs
#= require jquery-ui
#= require jquery.form
#= require jquery.remotipart
#= require jquery.pjax
#= require jquery.ba-resize
#= require rails.validations
#= require rails.validations.simple_form
#= require rails.validations.customValidators
#= require bootstrap
#= require jquery.jcarousel.min
#= require jquery.timeago.min
#= require ZeroClipboard
#= require jquery.mailcheck
#= require copy_button
#= require email
#= require petitions
#= require targets
#= require petition/categories_modal
#= require org/petition_selector
#= require pjax
#= require share
#= require twitter_intents
#= require facebook_share
#= require ./petition/flag
#= require upload_image
#= require collapse-arrow
#= require location_map
#= require embedly

$ -> $("form:not(.filter) :input[type=text]:visible:enabled:first").focus()

$ ->
  ClientSideValidations.formBuilders['SimpleForm::FormBuilder']['wrappers']["compact"] =
    add: (element, settings, message) ->
      wrapper = element.closest(settings.wrapper_tag)
      wrapper.addClass(settings.wrapper_error_class)
      errorElement = $("<#{settings.error_tag}/>", { class: settings.error_class, text: message })
      inputLabel = $('label[for=' + element.attr('id') + ']')
      errorElement.insertAfter(inputLabel)
    remove:  (element, settings) ->
      wrapper = element.closest("#{settings.wrapper_tag}.#{settings.wrapper_error_class}")
      wrapper.removeClass(settings.wrapper_error_class)
      errorElement = wrapper.find("#{settings.error_tag}.#{settings.error_class}")
      errorElement.remove()

$ ->
  $('input[rel=popover], textarea[rel=popover]').popover
    offset: 10, 
    trigger: "focus",
    html: true,
    template: '<div class="popover"><div class="arrow"></div><div class="popover-inner"><div class="popover-content"><p></p></div></div></div>'
    
  $('a[rel=popover]').popover
    offset: 10, 
    trigger: "hover",
    html: true,
    template: '<div class="popover"><div class="arrow"></div><div class="popover-inner"><div class="popover-content"><p></p></div></div></div>'

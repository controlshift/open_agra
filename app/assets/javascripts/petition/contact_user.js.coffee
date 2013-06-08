$ ->
  $('#view-contact-user-form').on 'click', ->
    modal = $('#contact-user-modal')

    if (modal.html().trim() != '')
      modal.modal()
    else
      # create the backdrop and wait for next modal to be triggered
      $('body').modalmanager('loading')
      $.get $('#view-contact-user-form').data().url, (data) ->
        modal.append(data)
        modal.modal()


$(document).ajaxComplete ->
  $('#new_email').enableClientSideValidations()

  process_captcha_image_src = ->
    simple_captcha_image = $(".simple_captcha_image img")
    original_url = simple_captcha_image.attr("src")
    if original_url
      relative_url = original_url.substring(original_url.indexOf("/simple_captcha"))
      simple_captcha_image.attr("src", relative_url)

  process_captcha_image_src()

  $("#btn-send").click ->
    form = $('#new_email')
    settings = window.ClientSideValidations.forms[form.attr('id')]
    @contact_url = $('#contact_user_form').data('contact-url')

    if form.isValid(settings.validators)
      $("#btn-send").hide()
      $("#img-send-loader").show()
      $("#label-send-error").hide()
      $(".simple_captcha_error").hide()

      $.ajax
        url: "#{@contact_url}.json"
        type: "post"
        data: $("#new_email").serialize()

        success: (resp) ->
          $("#btn-send").show()
          $("#img-send-loader").hide()
          $("#label-send-error").hide()
          $('#contact-user-modal').modal('hide')
          alert_message("Your message has been sent.")
          $('#contact-user-modal').empty()

        error: (jqXHR, textStatus, errorThrown) ->
          $("#btn-send").show()
          $("#img-send-loader").hide()
          json = eval('(' + jqXHR.responseText + ')')
          if (json['error_type'] == "captcha_failure")
            $(".simple_captcha_error").show()
            $(".simple_captcha_error").html(json['message'])
          else
            $("#label-send-error").show()
            $("#label-send-error").html(json['message'])
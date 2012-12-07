$ ->
    new FlagReasonDialog
class @FlagReasonDialog
   constructor: ->
     @confirm_button = $('#btn-flag')
     @flag_url = $('#flag-modal').data('flag-url')

     $('#flag-reason').keyup (event) =>
       throttle($(event), this.keyupHandler(), 250)
     @confirm_button.on 'click', (event) =>
       if $(event.target).hasClass('disabled')
         return
       this.submit()

   keyupHandler: ->
     reason_text = $('#flag-reason').val()
     if reason_text == ""
       @confirm_button.addClass('disabled')
     else
       @confirm_button.removeClass('disabled')


   submit: ->
     $.ajax
       url: @flag_url
       type: "post"
       data: { reason: $('#flag-reason').val() }
       dataType: 'json'

       success: (resp) ->
         $(".alert-success p").text(resp.notice)
         $(".alert-error").hide()
         $(".alert-success").show()
         $('#flag-modal').modal('hide')

       error: (jqXHR, textStatus, errorThrown) ->
         result = $.parseJSON(jqXHR.responseText)
         $(".alert-error p").text(result.notice)
         $(".alert-success").hide()
         $(".alert-error").show()
         $('#flag-modal').modal('hide')

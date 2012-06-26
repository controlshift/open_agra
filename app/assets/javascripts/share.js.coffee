root = exports ? this
root.alert_message = (message) ->
  $(".alert").hide()
  $(".alert.alert-success p").text(message)
  $(".alert.alert-success").show()
root.alert_message_error = (message) ->
  $(".alert").hide()
  $(".alert.alert-error p").text(message)
  $(".alert.alert-error").show()

clientSideValidations.callbacks.element.after = (element, eventData) ->
  errorSpan = $("span.help-inline", $(element).parent())
  inputLabel = $('label[for=' + element.attr('id') + ']')
  errorSpan.insertAfter(inputLabel)

# email address checking
domains = ['hotmail.com', 'gmail.com', 'aol.com', 'yahoo.com', 'yahoo.com.au', "bigpond.com", "optusnet.com.au", "tpg.com.au", "iinet.net.au"]

root.email_suggest_apply = (selector, value) ->
  $(selector).val(value)
  $(selector).siblings('.help-block').html("")
  
root.email_suggest = (selector) ->
  input = $(selector)
  input.focusout ->
    input.mailcheck domains, {
      suggested: (element, suggestion) ->
        suggestion_text = "Did you mean <strong><em><a href=\"javascript:email_suggest_apply('#{selector}', '#{suggestion['full']}')\">#{suggestion['full']}</a></em></strong>?"
        input.siblings('.help-block').html(suggestion_text)
      empty: (element) ->
        input.siblings('.help-block').html("")
    }
    
root.throttle = (context, fn, delay) ->
  timer = null
  ->
    args = arguments
    clearTimeout(timer)
    callback = -> fn.apply(context, args)
    timer = setTimeout(callback, delay)
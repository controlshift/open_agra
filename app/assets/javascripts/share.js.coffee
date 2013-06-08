root = exports ? this
root.alert_message = (message) ->
  $(".alert").hide()
  $(".alert.alert-success p").text(message)
  $(".alert.alert-success").show()
root.alert_message_error = (message) ->
  $(".alert").hide()
  $(".alert.alert-error p").text(message)
  $(".alert.alert-error").show()


# email address checkin
root.throttle = (context, fn, delay) ->
  timer = null
  ->
    args = arguments
    clearTimeout(timer)
    callback = -> fn.apply(context, args)
    timer = setTimeout(callback, delay)
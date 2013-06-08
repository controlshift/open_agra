#$(document).ajaxError (event, xhr, ajaxOptions, thrownError) ->
#  if thrownError is 'canceled' or xhr.status is 401 or xhr.status is 406
#    return
#  mesg = 'We have encountered an issue : '
#  mesg += thrownError
#  mesg += '. Do you want to reload the page and try again?'
#
#  if confirm(mesg)
#    window.location.reload()
#  else
#    $(".alert-error p").text(thrownError)
#    $(".alert-error").show()
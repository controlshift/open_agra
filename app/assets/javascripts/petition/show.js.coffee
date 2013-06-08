#= require ./comments
#= require ./sign
#= require ./contact_user

$ -> 
  if $.cookie('signature_id') != undefined
    $("#facebook-modal").modal()
    $.removeCookie 'signature_id'

  # set up embedly
  url = "/cached_url/"
  $('.petition-text a').embedly({resize_content: '.content-wrapper', maxWidth: 460, url: url})



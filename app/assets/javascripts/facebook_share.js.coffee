class @FacebookShare
  constructor: (callback) ->
    @fb_callback = callback ? ->

    $('a.facebook').on 'click', (event)  =>
      anchor = $(event.target).closest('a')
      targetURL = anchor.data('href')
      window.open(targetURL ,'sharer','toolbar=0,status=0,width=626,height=436')
      @fb_callback()
      if _gaq?
        _gaq.push(['_trackSocial', 'facebook', 'send', targetURL])
      false
class @FacebookShare
  constructor: (callback) ->
    @fb_callback = callback ? ->

    $('a.facebook').on 'click', (event)  =>
      @fb_callback()
      anchor = $(event.target).closest('a')
      url = anchor.data('href')
      this.openShareBox(url, anchor.data('slug'), anchor.data('vid'))
      false

  openShareBox: (url, @slug, @vid) ->
    window.open(url,'sharer','toolbar=0,status=0,width=626,height=436')
    if _gaq?
      _gaq.push(['_trackSocial', 'facebook', 'send', url])

    if @vid != 'none'
      $.ajax
        url: "/petitions/#{@slug}/facebook_share_variants/#{@vid}"
        type: "put"
        data: { }
        dataType: 'json'

    false


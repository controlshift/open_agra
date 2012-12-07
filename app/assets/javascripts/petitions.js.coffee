window.petitions =
  initForm: (popover = true) ->
    $ -> $(":input[type=text]:visible:enabled:first").popover('show') if popover

root = exports ? this

$ ->
  root.setupCopyEmailTempalteButton = (copyButton, buttonID, copyFieldID) ->
    copyButton.setHandCursor true
    copyButton.addEventListener "onComplete", ->
      $("#" + buttonID).twipsy "show"

    copyButton.addEventListener "mouseOver", ->
      copyButton.setText document.getElementById(copyFieldID).value

    $("#email_template").bind "shown", ->
      copyButton.glue buttonID, "email_template"

  root.setupCopyButton = (copyButton, buttonID, copyFieldID) ->
    copyButton.setHandCursor true
    copyButton.addEventListener "mouseOver", ->
      copyButton.setText document.getElementById(copyFieldID).value
    copyButton.glue buttonID

  root.reposition = ->
    copyButtonBody = new ZeroClipboard.Client()
    copyButtonBody.reposition "body_button", "email_template"

  root.initCopyButtons = ->
    copyButtonBody = new ZeroClipboard.Client()
    setupCopyEmailTempalteButton copyButtonBody, "body_button", "body-field"

    resizeTimer = undefined
    $(window).resize ->
      clearTimeout resizeTimer
      resizeTimer = setTimeout(reposition, 100)

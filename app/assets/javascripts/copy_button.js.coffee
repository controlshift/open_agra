root = exports ? this

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
  copyButtonSubject = new ZeroClipboard.Client()
  copyButtonBody = new ZeroClipboard.Client()
  copyButtonSubject.reposition "subject_button", "email_template"
  copyButtonBody.reposition "body_button", "email_template"
  
root.initCopyButtons = ->
  copyButtonSubject = new ZeroClipboard.Client()
  setupCopyEmailTempalteButton copyButtonSubject, "subject_button", "subject-field"
  copyButtonBody = new ZeroClipboard.Client()
  setupCopyEmailTempalteButton copyButtonBody, "body_button", "body-field"
  copyButtonPetitionUrl = new ZeroClipboard.Client()
  setupCopyButton copyButtonPetitionUrl, "copy_petition_url_button", "petition-url-field"

  resizeTimer = undefined
  $(window).resize ->
    copyButtonPetitionUrl.reposition()
    clearTimeout resizeTimer
    resizeTimer = setTimeout(reposition, 100)

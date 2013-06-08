window.Cs.sidebarFixer = () -> 
  doc_height = $(window).height()
  if doc_height < $('#sign_petition').height()
    $('.sidebar #content').removeClass('fixed')
    showSignatures()
  else
    $('.sidebar #content').addClass('fixed')
    hideSignatures()

sidebarContentInitialTop = 30

$(window).load ->
  sidebarContentInitialTop = parseInt($('.sidebar #content').css('top'), 10)

$ ->

  $(document).ready ->
    window.Cs.sidebarFixer()
  
  $(window).resize ->
    window.Cs.sidebarFixer()

  # fix sign height on scroll and page load
  fixSignHeight()
  $(window).scroll  ->
    fixSignHeight()
    window.Cs.sidebarFixer()

fixSignHeight = () ->
  num = sidebarContentInitialTop - $(window).scrollTop()
  if num < 10
    num = 10
  $('.fixed').css('top', num + 'px')
  $('#height-fixer').height(60 - $(window).scrollTop())

hideSignatures = () ->
  remaining_height = $(window).height() - $('#content hr.sign').position().top - 50 - 68
  $('.signature-box').show()
  each_signature_height = $('.signatures-box li').height() + 10
  number_of_signs = remaining_height/each_signature_height
  if number_of_signs >= 1
    $('.signatures-box li').each (index, element) ->
      if index >= (number_of_signs - 1)
        $(element).hide()
      else
        $(element).show()
  else
    $('.signature-box').hide()

showSignatures = () ->
  $('.signature-box').show()
  $('.signatures-box li').show()

$ ->
  window.ClientSideValidations.callbacks.form.before = (form, eventData) ->
    if $('input:-webkit-autofill').length > 0
      form.resetClientSideValidations();


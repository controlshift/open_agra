#= require jquery.mailcheck

$ ->
  $('input.email.required').focusout ->
    new EmailField this


class EmailField
  constructor: (@field) ->

    $(@field).mailcheck({
      domains: @domains
      suggested: (element, suggestion) =>
        @suggestion = suggestion['full']
        this.setupSuggestionHelp()


      empty: (element) =>
        this.clearSuggestionHelp()
    })

  suggestion: ""
  domains:  ['hotmail.com', 'gmail.com', 'aol.com', 'yahoo.com', 'yahoo.com.au', "bigpond.com", "optusnet.com.au", "tpg.com.au", "iinet.net.au", "me.com", "mac.com",
              "live.com", "comcast.net", "googlemail.com", "msn.com", "hotmail.co.uk", "yahoo.co.uk",
              "facebook.com", "verizon.net", "sbcglobal.net", "att.net", "gmx.com", "mail.com"]

  setupSuggestionHelp: () ->
    suggestion_text = "Did you mean <strong><em><a id=\"mailcheck-email-suggestion\">#{@suggestion}</a></em></strong>?"
    $(@field).siblings('.help-block').html(suggestion_text)
    $('#mailcheck-email-suggestion').on 'click', =>
      this.selectSuggestion()

  clearSuggestionHelp: () ->
    $(@field).siblings('.help-block').html("")

  selectSuggestion: () ->
    $(@field).val(@suggestion)
    this.clearSuggestionHelp()
    $(@field).closest('form').resetClientSideValidations();

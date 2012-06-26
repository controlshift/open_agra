# This is a manifest file that'll be compiled into including all the files listed below.
# Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
# be included in the compiled file accessible from http://example.com/assets/application
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#= require jquery_ujs
#= require jquery.form
#= require jquery.remotipart
#= require jquery.pjax
#= require rails.validations
#= require bootstrap
#= require jquery.jcarousel.min
#= require jquery.timeago.min
#= require ZeroClipboard
#= require jquery.mailcheck
#= require application
#= require copy_button
#= require email
#= require location
#= require petitions
#= require pjax
#= require share
#= require stories
#= require twitter_intents
#

$ -> $("form:not(.filter) :input[type=text]:visible:enabled:first").focus()

$ ->
  $('input[rel=popover], textarea[rel=popover]').popover
    offset: 10, 
    trigger: "focus",
    html: true,
    template: '<div class="popover"><div class="arrow"></div><div class="popover-inner"><div class="popover-content"><p></p></div></div></div>'
    
  $('a[rel=popover]').popover
    offset: 10, 
    trigger: "hover",
    html: true,
    template: '<div class="popover"><div class="arrow"></div><div class="popover-inner"><div class="popover-content"><p></p></div></div></div>'

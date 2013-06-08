window.Cs.prepareCommentsUi = ->
  $("abbr.timeago").timeago()
  $('div.comments').tooltip(selector: 'a.tooltip-link')
  $('li.comment .icon-heart').each (index, object) -> # this makes sure that the like icons come correct
    if $.cookie($(this).closest('li.comment').attr('id').replace('comment', '')) is 'c'
      $(object).addClass 'selected'
      $(object).parent().attr 'href', 'javascript:void(0);' # disables the link of already liked comments by this user

$ ->
  $(".sidebar-box.comment").on 'ajax:beforeSend','#new_comment', ->
    $("#comment-spinner").show()
  $('div.comments').on 'click', 'li.comment .icon-heart', (event) -> # event attachment to all the models
    cookie_path = window.location.pathname
    if $('.back-label').length == 1
      cookie_path = $('.back-label a').attr 'href' 
    $.cookie($(event.target).closest('li.comment').attr('id').replace('comment', ''), 'c', { expires: 3, path: cookie_path })
    $(this).addClass 'selected'

  $('div.comments').on 'click', 'li.comment .icon-flag', ->
    $(this).mouseleave() #if the DOM is removed, it doesn't take the tooltip along with itself.

  $('div.comments').on 'mouseenter', 'li.comment', ->
    $(this).addClass('hovered')
    $(this).find('.details').show()

  $('div.comments').on 'mouseleave', 'li.comment', ->
    $(this).removeClass('hovered')
    $(this).find('.details').hide()

  $('div.comments').on 'click', '.flag-comment', ->
    elem = $(this)

    modal = $('#flag-comment-modal')
    # create the backdrop and wait for next modal to be triggered
    manager = $('body').modalmanager('loading')
    $.get elem.data('flag-captcha-url'), (data) ->
      modal.find('.modal-body').html(data)
      modal.modal()
    return false
  window.Cs.prepareCommentsUi()

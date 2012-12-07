#= require petition/manage/petition_share_accordion
#= require petition/manage/petition_alias

$ ->
#   $('a#manage-collect').pjax('[data-pjax-container]').live 'click', (event) ->
#       $('.loader').show()
#       pages.collect.select()
   $('a#manage-training').pjax('[data-pjax-container]', {success: -> pages.training.select()}).live 'click', (event) ->
     $('.loader').show()
     pages.training.select()
   $('a#manage-deliver').pjax('[data-pjax-container]', {success: -> pages.deliver.select()}).live 'click', (event) ->
     $('.loader').show()
     pages.deliver.select()
   $('a#manage-admins').pjax('[data-pjax-container]', {success: -> pages.admins.select()}).live 'click', (event) ->
     $('.loader').show()
     pages.admins.select()
   $('a#manage-start').pjax('[data-pjax-container]', {success: -> pages.getting_started.select()}).live 'click', (event) ->
     $('.loader').show()
     $('body').addClass('body-manage')

   $('[data-pjax-container]').on 'pjax:timeout', -> return false


@pages =
  settings_sidebar:
    initialize: ->
      alias = new PetitionAliasSelector

      $("#petition_campaigner_contactable").change ->
        contactable = $("#petition_campaigner_contactable").is(':checked') ? '1' : '0'
        $.ajax
          url: $('#petition_campaigner_contactable').data('petition-update-url')
          type: "POST"
          data: { petition: { campaigner_contactable: contactable }, _method: 'PUT' }

  getting_started:
    initialize: ->
      accordion = new PetitionShareAccordion
      ZeroClipboard.setMoviePath( '/ZeroClipboard.swf' )
      initCopyButtons()
      pages.settings_sidebar.initialize()
    select: ->
      pages.getting_started.initialize()
      pages.tabs.highlight('start')
  deliver:
    initialize: ->
      pages.settings_sidebar.initialize()
      $('.accordion-toggle').on 'click', ->
        parent = $(this).closest(".accordion")
        isExpanded = $(this).closest(".accordion-heading").siblings(".accordion-body").hasClass('in')
        $(".accordion-toggle", parent).removeClass('open')
        if !isExpanded
          $(this).addClass('open')

    select: ->
      pages.deliver.initialize()
      pages.tabs.highlight('deliver')

  training:
    select: ->
      pages.tabs.highlight('training')

  admins:
    initialize:  ->
      pages.settings_sidebar.initialize()
    select: ->
      pages.admins.initialize()
      pages.tabs.highlight('')

  collect:
    initialize: ->
      pages.settings_sidebar.initialize()
    select: ->
      pages.collect.initialize()
      pages.tabs.highlight('collect')

  tabs:
    highlight: (id) ->
      $('.campaign-tips').html('')
      $('.manage-tab').removeClass('highlighted')
      if id != ''
        $("#manage-#{ id }-tab").addClass('highlighted')





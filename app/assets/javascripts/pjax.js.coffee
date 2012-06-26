$ ->
  $('a.use-pjax').pjax('[data-pjax-container]').live 'click', (event) ->
      $('.loader').show()
      
  $('[data-pjax-container]').on 'pjax:timeout', -> return false

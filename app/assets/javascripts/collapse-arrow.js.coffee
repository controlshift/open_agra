$ ->
  $('.accordion-toggle').on 'click', ->
    $(this).siblings('.collapse-arrow').toggleClass('collapse-arrow-up collapse-arrow-down', 200);

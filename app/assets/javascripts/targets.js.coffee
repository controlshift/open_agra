$ ->
  $('#target_name').autocomplete
    source: $('#target_name').data('autocompleteSource')
    appendTo: ".control-group"
    minLength: 3
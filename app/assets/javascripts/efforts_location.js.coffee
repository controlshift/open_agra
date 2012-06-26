$ ->
  $("#location_query").keydown (event) ->
    if event.keyCode == 13
      name = $(".pac-item:first").text()
      geocoder = new google.maps.Geocoder()
      geocoder.geocode({ 'address': name }, on_geocode_result)
      event.preventDefault()
      false

  $("#search-effort").click ->
    name = $("#location_query").val()
    if name.length > 0
      geocoder = new google.maps.Geocoder()
      geocoder.geocode({ 'address': name }, on_geocode_result)
    false

  on_geocode_result = (results, status) ->
    if status == google.maps.GeocoderStatus.OK
      place = results[0]
      (new PlaceHelper(place)).bind_to_form(query_form, 'location')
      $('form.effort-location-search').submit()

  query_form = $('form.effort-location-search')

  autocomplete = new google.maps.places.Autocomplete(document.getElementById('location_query'))
  google.maps.event.addListener autocomplete, 'place_changed', ->
    place = autocomplete.getPlace()
    if place.geometry != undefined
      (new PlaceHelper(place)).bind_to_form(query_form, 'location')
      $('form.effort-location-search').submit()

#= require underscore
#= require backbone
#= require handlebars-runtime
#= require templates/locations/field
#= require templates/locations/efforts_near_field
#= require templates/locations/simple_location_field

$ ->
  class SimpleLocationField extends Backbone.View
    template:
      HandlebarsTemplates['templates/locations/simple_location_field']

    initialize: ->
      this.model.bind("autocomplete_complete", this.onAutocompleteComplete);
      this.model.bind("geocode_complete", this.onGeocoderComplete);

    events:
      "keydown #location-query-field": "onKeydown"

    onKeydown: (event) ->
      if event.keyCode == 13
        this.model.geocode()
        event.preventDefault()
        return true

    render: ->
      context = this.model.toJSON()
      this.$el.html(@template(context))
      @autocomplete = new Autocomplete(this.model)

    onAutocompleteComplete: =>
       this.render()

    onGeocoderComplete: =>
      this.render()
      if this.model.validated()
        this.$el.closest('form').submit()
      else
        this.$el.closest('form').trigger('form:validate:fail')
      return true

  class NearEffortField extends SimpleLocationField
    template:
      HandlebarsTemplates['templates/locations/efforts_near_field']

    onGeocoderComplete: =>
      this.render()
      if this.model.get("geocoder_success")
        this.$el.closest('form').submit()
      else
        alert('We did not understand that location.')
      return true

  class LocationField extends SimpleLocationField
    template:
      HandlebarsTemplates['templates/locations/field']

    initialize: ->
      super
      this.render()

    events:
      "click #location-query-field": "selectLocal"
      "change .national": "onSelectNational"
      "change .local": "onSelectLocal"
      "focus #location-query-field": "selectLocal"

    render: ->
      super
      this.$el.find('input[rel=popover], textarea[rel=popover]').popover
        offset: 10,
        trigger: "focus",
        html: true,
        template: '<div class="popover"><div class="arrow"></div><div class="popover-inner"><div class="popover-content"><p></p></div></div></div>'

    onSelectNational: ->
      this.model.clearAttributes()
      this.model.set('kind', 'national')
      this.render()

    onSelectLocal: ->
      this.model.set('kind', 'local')

    selectLocal: ->
      this.model.set('kind', 'local')
      this.$el.find('.local').attr('checked',true)

    selectNational: ->
      this.model.set('kind', 'national')
      this.$el.find('.national').attr('checked',true)

  class GeoSubmitButton extends Backbone.View

    events:
      "click .submit-button" : "codeAndSubmit"

    codeAndSubmit: ->
      this.model.geocode()
      return false

  class PetitionSaveButton extends GeoSubmitButton

    codeAndSubmit: ->
      if this.model.isLocal()
        this.model.geocode()
      else
        $('#location-query-field').val("")
        this.$el.closest('form').submit()

      return false

  class Location extends Backbone.Model
    defaults:
      geocoder_success: true
      geocoded: false
      kind: 'local'

    toJSON: ->
      json =  Backbone.Model.prototype.toJSON.apply(this, arguments)
      json.isLocal = this.isLocal()
      json.isNational = this.isNational()
      json.validated = this.validated()
      json.query_present = this.query_present()
      return json

    isLocal: ->
      ('local' == this.get('kind'))

    isNational: ->
      ('national' == this.get('kind'))

    geocode: ->
      this.set({geocoded: false, query:this.query_value() })
      if this.query_value()
        gc = new Geocoder(this)
        gc.lookup(this.query_value(), this.region())
      else
        this.clearAttributes()
        this.trigger("geocode_complete")

    validated: ->
      (this.get("query") && this.get("geocoder_success"))

    query_field: ->
      $('#location-query-field')

    query_field_element: ->
      this.query_field()[0]

    query_value: ->
      this.query_field().val()

    query_present: -> this.get('query')

    region: ->
      $('#efforts-near-container').data('organisation-country')

    clearAttributes: ->
      this.set(
        types: []
        latitude: null
        longitude: null
        locality: null
        region: null
        country: null
        postal_code: null
        street: null
      )

    processGeocode: (response, status) ->
      geocoder_success = (status == google.maps.GeocoderStatus.OK)
      if geocoder_success
        response = _.first(response)
        this.fromGoogleResponse(response, status)
      else
        this.clearAttributes()
        this.set(
          geocoder_status: status
          geocoder_success: geocoder_success
          geocoded: true
        )
      this.trigger("geocode_complete")

    processAutocomplete: (response) ->
      this.fromGoogleResponse(response)
      this.trigger("autocomplete_complete")


    fromGoogleResponse: (response, status = google.maps.GeocoderStatus.OK) ->
      new_values =
        geocoder_success: (status == google.maps.GeocoderStatus.OK)
        geocoder_status: google.maps.GeocoderStatus.OK
        geocoded: true
        types: response.types
        latitude: response.geometry.location.lat()
        longitude: response.geometry.location.lng()

      for address_component in response.address_components
        for type in address_component.types
          switch(type)
            when "locality" then _.extend(new_values, {locality: address_component.short_name})
            when "administrative_area_level_1" then  _.extend(new_values, {region: address_component.short_name})
            when "country" then _.extend(new_values, {country: address_component.short_name})
            when "postal_code" then _.extend(new_values, {postal_code: address_component.short_name})
            when "route"
              if (typeof new_values.street  == 'undefined')
                _.extend(new_values, {street: address_component.short_name})
            when "street_address" then _.extend(new_values, {street: address_component.short_name})

      this.set(new_values)
      

  class Autocomplete
    constructor: (@loc) ->
      options = {}
      if (@loc.region() != undefined && @loc.region().length)
        options = { componentRestrictions: {country: @loc.region()} }

      autocomplete = new google.maps.places.Autocomplete(@loc.query_field_element(), options)
      google.maps.event.addListener autocomplete, 'place_changed', =>
        @loc.set({query: @loc.query_value()})
        place = autocomplete.getPlace()
        if place.geometry != undefined
          @loc.processAutocomplete(place)

  class Geocoder
    constructor: (@loc) ->
      @client = new google.maps.Geocoder

    lookup: (query, region) ->
      @client.geocode({'address': query, 'region': region}, this.processLocations);

    processLocations: (response, status) =>
      @loc.processGeocode(response, status)

  if $('#location-container').length
    elem = $('#location-container')
    loc = new Location( kind: elem.data('location-kind'), query: elem.data('location-query'), help_text: elem.data('location-help-text'))
    location_field =  new LocationField( model: loc, el: $('#location-container')  )
    petition_save_button =  new PetitionSaveButton( model: loc, el: $('#petition-save-button'))
    autocomplete = new Autocomplete(loc)

  if $('.effort-location-search').length
    loc = new Location
    field = new NearEffortField(model: loc, el: $('#efforts-near-container'))
    nearEffortSearchButton = new GeoSubmitButton( model: loc, el:$('#efforts-near-container'))
    autocomplete = new Autocomplete(loc)

  if $('#targets-location').length
    loc = new Location
    field = new SimpleLocationField(model: loc, el: $('#targets-location'))
    target_save_button =  new GeoSubmitButton( model: loc, el: $('#target-save-button'))
    autocomplete = new Autocomplete(loc)

  $('#location-categories input,#location-categories select').change ->
    $(this).closest('form').submit()

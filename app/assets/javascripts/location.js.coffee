class @PlaceHelper
  constructor: (@place) ->
    
  bind_to_form: (form, namespace) ->
    $("input[name~='#{namespace}[types][]']", form).remove()
    for type in @place.types
      input = "<input type='hidden' name='#{namespace}[types][]' value='#{type}'>"
      form.append(input)
    
    setInputValue(namespace, form, "latitude", @place.geometry.location.lat())
    setInputValue(namespace, form, "longitude", @place.geometry.location.lng())

    for field in ['locality', 'region', 'country', 'postal_code', 'street']
      setInputValue(namespace, form, field, '')

    for address_component in @place.address_components
      for type in address_component.types
        if type == "locality"
          setInputValue(namespace, form, "locality", address_component.short_name)
          break
        else if type == "administrative_area_level_1"
          setInputValue(namespace, form, "region", address_component.short_name)
          break
        else if type == "country"
          setInputValue(namespace, form, "country", address_component.short_name)
          break
        else if type == "postal_code"
          setInputValue(namespace, form, "postal_code", address_component.short_name)
          break
        else if type == "route"
          setInputValue(namespace, form, "street", address_component.short_name)
          break
          
  setInputValue = (namespace, form, name, value) ->
    if $("input[name='#{namespace}[#{name}]']", form).length > 0
      $("input[name='#{namespace}[#{name}]']", form).val(value)
    else
      input = "<input type='hidden' name='#{namespace}[#{name}]' value='#{value}'>"
      form.append(input)

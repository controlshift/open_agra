window.petitions =
  initForm: ->
    new petitions.UploadImage $(".upload-image")
    $ -> $(":input[type=text]:visible:enabled:first").popover('show')
    
  UploadImage: class
    constructor: (@element) ->
      @field = @element.find("#petition_image")
      @image = @element.find(".preview-image img")
      @field.change => this.imageChanged()
    
    imageChanged: ->
      @image.attr("src", @element.data("changed-placeholder-url"))
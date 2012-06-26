window.stories =
  initForm: ->
    new stories.UploadImage $(".upload-image")
    
  UploadImage: class
    constructor: (@element) ->
      @field = @element.find("#story_image")
      @image = @element.find(".preview-image img")
      @field.change => this.imageChanged()
    
    imageChanged: ->
      @image.attr("src", @element.data("changed-placeholder-url"))
      $('#new_story .upload-field .help-inline').text('')
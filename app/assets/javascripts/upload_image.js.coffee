$ ->
  class UploadImage
    constructor: (@element) ->
      field = @element.find("input")
      @image = @element.find(".preview-image img")
      field.change =>
        url = @element.data("changed-placeholder-url")
        @image.attr("src", url)

  $('.upload-image-switcher').each ->
    new UploadImage($(this))
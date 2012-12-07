class @CategoriesModal
  constructor: ->
    $("#category-modal .btn-primary").click =>
      this.onSave()
    $("#category-modal .close").click =>
      this.onClose()
    @petitionCategoriesUpdatePath = $("#category-modal").data('petition-categories-update-path')
    @currentCategories = this.categoriesFromPage()

  categoriesFromPage: ->
    $(".petition-form input:checked").map ->
      { id: $(this).val(), name: $(this).siblings('label').text() }

  onSave: ->
    @currentCategories = this.categoriesFromPage()
    this.persistCategories(@currentCategories)

    $('#category-modal').modal('hide')
    return false

  onClose: ->
    this.resetCategories(@currentCategories)
    $('#category-modal').modal('hide')

  resetCategories: (categories) ->
    $("#category-modal .petition-form input").attr('checked', false)
    for category in categories
      $("#petition_category_ids_" + category.id).attr('checked', true)

  persistCategories: (categories) =>
    categoryIds = []
    categoryIds.push(c.id) for c in categories

    if categoryIds.length == 0
      categoryIds.push("")

    $.ajax
      type: 'POST'
      url: "#{@petitionCategoriesUpdatePath}"
      data: { 'petition': { 'category_ids': categoryIds }, '_method': 'PUT' }


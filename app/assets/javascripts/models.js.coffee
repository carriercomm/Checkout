jQuery ->
  # setup the popover options
  my_template = [
    '<div class="popover">',
      '<div class="arrow"></div>',
      '<div class="popover-inner">',
        '<h3 class="popover-title"></h3>',
        '<a id="category_suggestion_close" class="close popover-close">×</a>',
        '<div id="category_suggestion_content" class="popover-content"><p></p></div>',
      '</div>',
    '</div>'
  ].join("")

  options = 
    title: "Category Suggestions"
    placement: 'top'
    trigger: 'manual'
    template: my_template

  # create the popover
  $('#suggestion_popover').popover(options)

  showPopover = ->
    $('#suggestion_popover').popover('show')
    console.log "shown"
    # destroy all the "close" click handlers
    $('#category_suggestion_close').off('click')
    console.log "click off"
    # recreate the "close" click handler
    $('#category_suggestion_close').on 'click', ->
      console.log "clicked"
      # hide the popover
      $('#suggestion_popover').popover 'hide'
      return false

  # setup a handler to fire off the ajax request for category suggestions
  $('.categories-select').bind 'change', ->
    # data structure to send our ajax query params
    data =
      category_ids: []
    # fill the data structure
    $(this).find('option:selected').each (i, opt) ->
      data.category_ids.push($(opt).val())
    # define function for handling ajax response
    success = (data) ->
      values = []
      # build up a link for each return value
      $.each data, (index, value) ->
        link = '<a href="#" class="category-suggestion-link" data-id="' + value.id + '">' + value.name + '</a>'
        values.push link
      # bail if there's nothing to show
      return if values.length == 0
      # show the popover
      showPopover()
      # set the popover's content
      $('#category_suggestion_content p').html(values.join(", "))
      # set click handlers for the links in the content
      $('.category-suggestion-link').click ->
        id   = $(this).data("id")
        name = $(this).html()
        # temporarily destroy the tokenized select box
        $('.select2-tagged-field.categories-select').select2("destroy")
        # add our new category, as a selected option
        $(".categories-select").append('<option value="' + id + '" selected>' + name + '</option>')
        # recreate the tokenized select box
        $('.select2-tagged-field.categories-select').select2()
        return false

    # setup the ajax request
    ajax_opts =
      url: '/categories/suggestions.json'
      success: success
      data: data

    # make the ajax request
    $.ajax ajax_opts

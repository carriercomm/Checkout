jQuery ->
  $.widget( "custom.catcomplete", $.ui.autocomplete,
      _renderMenu: (ul, items) ->
        that = this
        currentCategory = ""
        $.each(items, (index, item) ->
          if (item.category != currentCategory)
            ul.append( "<li class='ui-autocomplete-category'>" + item.category + "</li>" )
            currentCategory = item.category
          that._renderItemData(ul, item)
        )

      _renderItem: (ul, item) ->
        term = this.term.split(' ').join('|')
        re   = new RegExp("(" + term + ")", "gi")
        t    = item.label.replace(re,"<b>$1</b>")
        return $( "<li></li>" )
           .data( "item.autocomplete", item )
           .append( "<a>" + t + "</a>" )
           .appendTo( ul )

  )

  $("#q").catcomplete(
    delay: 100
    minLength: 2
    source: (request, response) ->
      $.getJSON("/search", { q: request.term }, (result) ->
        response(result)
      )
    autoFocus: true
    focus: (event, ui) ->
      false
    select: (event, ui) ->
      window.location = ui.item.value
      false
  )

  # $("#k").catcomplete(
  #   delay: 100
  #   minLength: 2
  #   source: (request, response) ->
  #     $.getJSON("/search", { k: request.term }, (result) ->
  #       response(result)
  #     )
  #   autoFocus: true
  #   focus: (event, ui) ->
  #     false
  #   select: (event, ui) ->
  #     window.location = ui.item.value
  #     false
  # )
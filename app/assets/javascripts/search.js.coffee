jQuery ->
  $.ui.autocomplete.prototype._renderItem = ( ul, item) ->
    term = this.term.split(' ').join('|')
    re   = new RegExp("(" + term + ")", "gi")
    t    = item.label.replace(re,"<b>$1</b>")
    return $( "<li></li>" )
       .data( "item.autocomplete", item )
       .append( "<a>" + t + "</a>" )
       .appendTo( ul );

  $(".navbar input").autocomplete(
    delay: 100
    minLength: 2
    source: (request, response) ->
      $.getJSON("/search", { q: request.term }, (result) ->
        response(result)
      )
    focus: (event, ui) ->
      false
    select: (event, ui) ->
      window.location = ui.item.value
      false
  )

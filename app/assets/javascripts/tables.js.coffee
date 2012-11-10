jQuery ->
  ellipsize = ->
    $("td.ellipsize").each ->
      _this = $(this)
      width = _this.width()
      _this.find("div")
        .width(width)
        .addClass("truncate")
        .tooltip()
    
  ellipsize()

  # FIXME: performance suckage
  $(window).resize ->
    $("td.ellipsize").find("div").width("").removeClass("truncate")
    ellipsize()
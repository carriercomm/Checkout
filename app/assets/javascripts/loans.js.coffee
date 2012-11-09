# TODO: move some of this logic to an AJAX call to the server.  It
#       won't scale as-is. There's also an issue of refining the
#       return dates based on the date_start selection - it will be
#       easier to keep track of on the server side.

jQuery ->
  # hide the date pickers and kit field
  if $("#loan_location").val() == ""
    $(".control-group.date_picker").addClass("hidden")
    $("#loan_kit").closest(".control-group").addClass("hidden")


  if typeof gon != "undefined"
    # convert the dates_open and days_reservable from an array of
    # strings to properties of type date on the object. this makes it
    # simple to do constant-time lookup to see if the date exists
    if gon.locations  
      for id, location of gon.locations
        # handle days_reservable
        for kit in location.kits
          days_reservable = kit.days_reservable[..]
          kit.days_reservable = {}
          for d in days_reservable
            day = new Date(Date.parse(d))
            kit.days_reservable[day] = true

        # handle dates_open
        dates_open = location.dates_open[..]
        location.dates_open = {}
        for d in dates_open
          day = new Date(Date.parse(d))
          location.dates_open[day] = true
        
    # check if we need to snag the suggested return day/month from the form
    if !gon.default_return_date
      ends_at = $('#loan_ends_at').val()
      gon.default_return_date = new Date(Date.parse(ends_at))



  # update the ID of the current active location when the location
  # select box changes
  $("#loan_location").change (val) ->
    if $(this).val() == ""
      $(".control-group.date_picker").addClass("hidden")
    else
      $(".control-group.date_picker").removeClass("hidden")  
    # clear out the date fields
    $("#loan_starts_at").val(null)
    $("#load_ends_at").val(null)
    gon.default_return_date = null


  # once a pick up date is selected, automatically calculate the
  # return date based on the default_checkout_length
  $("#loan_starts_at").change (e) ->
    ends_at = new Date($(this).datepicker("getDate"))

    if ends_at == null || gon.default_checkout_length == null
      return

    # add the default checkout length to the start date to get the
    # approximate return date
    ends_at.setDate(ends_at.getDate() + gon.default_checkout_length)

    # check the approximate return date against the dates the
    # location is open
    active_location = parseInt($("#loan_location").val())

    # fetch the location's open dates from gon
    location = if gon && gon.locations && active_location then gon.locations[active_location] else []

    # find the nearest open day which is either the approximate
    # return date, or after it
    for date_open, x of location.dates_open
      date_open = new Date(date_open)
      if date_open >= ends_at
        ends_at = date_open
        # break out of the for loop, since we're done
        break

    # populate the calculated return date
    $("#loan_ends_at").datepicker("setDate", ends_at)

    # also stash the date for reference, in case the user decides to
    # change the return date
    gon.default_return_date = ends_at


  # configure the start_date datepicker
  $("#loan_starts_at").datepicker(
    altFormat: "yy/mm/dd",
    dateFormat: "yy/mm/dd",
    minDate: "-0d",
    maxDate: "+90d",
    showOtherMonths: true,
    selectOtherMonths: true,
    beforeShowDay: (date)->
      # fetch the location_id from the location select box
      active_location = parseInt($("#loan_location").val())

      # fetch the location's open dates from gon
      location = if gon && gon.locations && active_location then gon.locations[active_location] else []

      # decide whether to activate this day by iterating over the
      # available kits, looking for one that's avaiable on this day
      for kit in location.kits
        if kit.days_reservable[date]
          return [true]
      return [false]
  )

  # configure the end_date datepicker
  $("#loan_ends_at").datepicker(
    altFormat: "yy/mm/dd",
    dateFormat: "yy/mm/dd",
    minDate: "-0d",
    maxDate: "+90d",
    showOtherMonths: true,
    selectOtherMonths: true,
    beforeShow: (input, inst) ->
      # grab the start date so we have a starting reference point
      start_date  = $("#loan_starts_at").datepicker("getDate") || Date.parse($("#loan_out_at").val())
      return unless start_date

      # restrict the available return dates to on/after the start_date
      $("#loan_ends_at").datepicker("option", "minDate", new Date(start_date))

    beforeShowDay: (date)->
      # fetch the location_id from the location select box
      active_location = parseInt($("#loan_location").val())

      # fetch the location's open dates from gon
      location = if gon && gon.locations && active_location then gon.locations[active_location] else []

      # if this day is in the set of open dates, then thumbs up
      if location.dates_open[date]
        if gon.default_return_date
          if date <= gon.default_return_date
            return [true, "return-date-ok", "No additional approval required"]
          else
            return [true, "return-date-warn", "Requires approval"]
        else
          return [true]
      return [false]
  )

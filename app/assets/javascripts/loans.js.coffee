jQuery ->
  $(document).ready ->
    # store the ID of the current active location (if there is one)
    # $("#loan_location option:selected").each (i) ->
    #   window.gon.active_location = parseInt($(this).val())

    # hide the date pickers and kit field
    if $("#loan_location").val() == ""
      $(".control-group.date_picker").addClass("hidden")
      $("#loan_kit").closest(".control-group").addClass("hidden")



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
      date = new Date($(this).datepicker("getDate"))
      if date == null || gon.default_checkout_length == null
        return

      # add the default checkout length to the start date to get the
      # approximate return date
      date.setDate(date.getDate() + gon.default_checkout_length)

      # check the approximate return date against the dates the
      # location is open
      active_location = parseInt($("#loan_location").val())

      # fetch the location's open dates from gon
      location = if gon && gon.locations && active_location then gon.locations[active_location] else []

      for date_open in location.dates_open
        this_day    = date.getDate()
        this_month  = date.getMonth()
        open_day    = date_open[1]
        open_month  = date_open[0]-1

        # find the nearest open day which is either the approximate
        # return date, or after it
        if (open_day >= this_day && open_month >= this_month)
          date.setDate(open_day)
          date.setMonth(open_month)
          # break out of the for loop, since we're done
          break

      # populate the calculated return date
      $("#loan_ends_at").datepicker("setDate", date)

      # also stash the date for reference, in case the user decides to
      # change the return date
      gon.default_return_date = date


  # configure the start_date datepicker
  $("#loan_starts_at").datepicker(
    altFormat: "yy-mm-dd",
    dateFormat: "yy-mm-dd",
    minDate: "-0d",
    maxDate: "+90d",
    showOtherMonths: true,
    selectOtherMonths: true,
    beforeShowDay: (date)->
      # fetch the location_id from the location select box
      active_location = parseInt($("#loan_location").val())

      # fetch the location's open dates from gon
      location = if gon && gon.locations && active_location then gon.locations[active_location] else []

      # TODO: get rid of this incessant looping! This should be a
      #       constant-time lookup. Convert the array to some kind of hash.
      # decide whether to activate this day by iterating of the available kits
      for kit in location.kits
        for day_reservable in kit.days_reservable
          if(day_reservable[1] == date.getDate() && (day_reservable[0]-1) == (date.getMonth()))
            return [true]
      return [false]
  )

  # configure the end_date datepicker
  $("#loan_ends_at").datepicker(
    altFormat: "yy-mm-dd",
    dateFormat: "yy-mm-dd",
    minDate: "-0d",
    maxDate: "+90d",
    showOtherMonths: true,
    selectOtherMonths: true,
    beforeShow: (input, inst) ->
      # grab the start date so we have a starting reference point
      start_date  = $("#loan_starts_at").datepicker("getDate")
      return unless start_date

      # restrict the available return dates to on/after the start_date
      inst.settings.minDate = new Date(start_date)

    beforeShowDay: (date)->
      # fetch the location_id from the location select box
      active_location = parseInt($("#loan_location").val())

      # get the day and month for comparison
      this_day    = date.getDate()
      this_month  = date.getMonth()
  
      # get the suggested return day/month, if available
      default_return_day   = gon.default_return_date.getDate() if gon and gon.default_return_date
      default_return_month = gon.default_return_date.getMonth() if gon and gon.default_return_date

      # fetch the location's open dates from gon
      location = if gon && gon.locations && active_location then gon.locations[active_location] else []

      # grab the start date so we have a starting reference point
      # start_date  = $("#loan_starts_at").datepicker("getDate")

      # TODO: get rid of this incessant looping! This should be a
      #       constant-time lookup. Convert the array to some kind of hash.
      # figure out the legal days

      for date_open in location.dates_open
        # start_day   = start_date.getDate()
        # start_month = start_date.getMonth()
        open_day    = date_open[1]
        open_month  = date_open[0]-1

        # if this date comes before the start_date then throw it out
        # if (this_day < start_day && this_month <= start_month)
        #   return [false]

        # if this day is in the set of open dates, then thumbs up
        if (open_day == this_day && open_month == this_month)
          if (gon.default_return_date && ((this_day <= default_return_day && this_month == default_return_month) || this_month < default_return_month))
            return [true, "return-date-ok", "No additional approval required"]
          else
            return [true, "return-date-warn", "Requires approval"]
      return [false]
  )

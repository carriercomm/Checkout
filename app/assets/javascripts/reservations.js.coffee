jQuery ->
  $(document).ready ->
    # store the ID of the current active location (if there is one)
    $("#reservation_location option:selected").each (i) ->
      window.gon.active_location = parseInt($(this).val())

    # update the ID of the current active location when the location
    # select box changes
    $("#reservation_location").change (val) ->
      window.gon.active_location = parseInt(val.srcElement.value)

      # clear out the date fields
      $("input.start_date").val(null);
      $("input.end_date").val(null);


  # configure the start_date datepicker
  $("input.start_date").datepicker(
    altFormat: "yy-mm-dd",
    dateFormat: "yy-mm-dd",
    minDate: "-0d",
    # TODO: parameterize this range
    maxDate: "+90d",
    showOtherMonths: true,
    selectOtherMonths: true,
    beforeShowDay: (date)->
      location = if gon && gon.locations then gon.locations[gon.active_location] else []
      for kit in location.kits
        kit_id = kit.kit_id
        for day_reservable in kit.days_reservable
          if(day_reservable[1] == date.getDate() && (day_reservable[0]-1) == (date.getMonth()))
            return [true]
      return [false]
  )

  # configure the end_date datepicker
  $("input.end_date").datepicker(
    altFormat: "yy-mm-dd",
    dateFormat: "yy-mm-dd",
    minDate: "-0d",
    # TODO: parameterize this range
    maxDate: "+90d",
    showOtherMonths: true,
    selectOtherMonths: true,
    beforeShowDay: (date)->
      # get the data objects associated with this location
      location   = if gon && gon.locations then gon.locations[gon.active_location] else []

      # FIXME: THIS CODE IS HORRIBLE!!

      # grab the start date so we have a starting reference point
      start_date  = $("input.start_date").val()

      if !start_date
        return [false]

      start_month = parseInt(start_date.split("-")[1])
      start_day   = parseInt(start_date.split("-")[2])
      cal_month   = date.getMonth() + 1
      cal_day     = date.getDate()

      # figure out the legal days
      for kit in location.kits
        kit_id = kit.kit_id
        for day_reservable in kit.days_reservable
          if day_reservable[1] == cal_day and day_reservable[0] == cal_month and start_month <= cal_month
            if start_month == cal_month
              if start_day <= cal_day
                return [true]
              else
                return [false]
            return [true]
      return [false]
  )

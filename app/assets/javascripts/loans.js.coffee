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
    # convert the pickup_dates from an array of strings to properties
    # of type date on the object. this makes it simple to do
    # constant-time lookup to see if the date exists
    if gon.locations  
      for id, location of gon.locations
        for kit in location.kits
          # handle pickup_dates
          pickup_dates = kit.pickup_dates[..]
          kit.pickup_dates = {}
          location.pickup_dates = {}
          for d in pickup_dates
            day = new Date(Date.parse(d))
            kit.pickup_dates[day] = true
            location.pickup_dates[day] = true

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


  # once a pickup date is selected, automatically calculate the
  # return date based on the default_checkout_length
  $("#loan_starts_at").change (e) ->
    starts_at = $(this).datepicker("getDate")

    if starts_at == null || gon.default_checkout_length == null || gon.default_checkout_length == undefined
      console.log("min_date or default_checkout_length was null or undefined")
      return

    # use the start date as a starting point for determining the return date
    min_date = new Date(starts_at)

    # add the default checkout length to the start date to get the
    # approximate return date
    min_date.setDate(min_date.getDate() + gon.default_checkout_length)
    console.log(min_date)

    # check the approximate return date against the locations pickup
    # dates
    active_location = parseInt($("#loan_location").val())

    # fetch the location's pickup dates from gon
    location = []
    if gon && gon.locations && active_location
      location = gon.locations[active_location]
    else
      console.log("couldn't fetch the open dates from gon")
  
    # set our candidate date to one year in the future. we'll pull it
    # down iteratively
    ends_at = new Date(min_date)
    ends_at.setFullYear(min_date.getFullYear() + 1)

    # find the nearest pickup day which is either the approximate
    # return date, or after it
    for pickup_date, x of location.pickup_dates
      pickup_date = new Date(pickup_date)
      if pickup_date >= min_date and pickup_date < ends_at
        ends_at = pickup_date

    ends_at = ends_at.getFullYear() + "/" + (ends_at.getMonth() + 1) + "/" + ends_at.getDate()
    $('input[name="loan[ends_at]"]').val(ends_at)

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

      # decide whether to activate this day looking it up in the location.pickup_dates array
      if location.pickup_dates[date]
        return [true]
      return [false]
  )
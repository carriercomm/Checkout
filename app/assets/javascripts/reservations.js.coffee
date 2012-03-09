jQuery ->
  $(".datepicker").datepicker(
    altFormat: "yyyy-mm-dd",
    minDate: "-0d",
    # TODO: parameterize this range
    maxDate: "+90d",
    showOtherMonths: true,
    selectOtherMonths: true,
    beforeShowDay: (date)->
      openDates = if gon then gon.days_open else []
      for openDate in openDates
        if(openDate[1] == date.getDate() && (openDate[0]-1) == (date.getMonth()))
          return [true]
      return [false]
  )

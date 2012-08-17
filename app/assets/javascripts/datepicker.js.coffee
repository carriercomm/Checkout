jQuery ->
  # configure the suspended_until datepicker
  $("input.generic_datepicker").datepicker(
    altFormat: "yy-mm-dd",
    dateFormat: "yy-mm-dd",
    minDate: "-0d",
    # TODO: parameterize this range
    maxDate: "+90d",
    showOtherMonths: true,
    selectOtherMonths: true
  )
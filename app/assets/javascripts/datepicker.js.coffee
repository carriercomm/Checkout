jQuery ->
  # configure the suspended_until datepicker
  $("input.generic_datepicker").datepicker(
    altFormat: "yy-mm-dd",
    dateFormat: "yy-mm-dd",
    minDate: "-0d",
    showOtherMonths: true,
    selectOtherMonths: true
  )
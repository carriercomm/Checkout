jQuery ->
  # configure the start_date datepicker
  $("#group_expires_at").datepicker(
    altFormat: "yy-mm-dd",
    dateFormat: "yy-mm-dd",
    minDate: "-0d",
    showOtherMonths: true,
    selectOtherMonths: true
  )
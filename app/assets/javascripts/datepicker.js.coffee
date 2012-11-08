# NOTE: some non-generic datepicker-related code can also be found in loans.js.coffee

jQuery ->
  bindDatepicker = ->
    $("input.date_picker")
      .filter ->
        return !(this.id == 'loan_starts_at' or this.id == 'loan_ends_at')
      .datepicker(
        altFormat: "yy/mm/dd",
        dateFormat: "yy/mm/dd",
        minDate: "-0d",
        showOtherMonths: true,
        selectOtherMonths: true
      )

  bindDatepicker()

  $('form').bind 'nested:fieldAdded', ->
    bindDatepicker()
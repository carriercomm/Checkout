# NOTE: some non-generic datepicker-related code can also be found in loans.js.coffee

jQuery ->
  bindDatepicker = ->
    $("input.generic_datepicker")
      .filter ->
        return !this.id.match(/[a-z_]+_attributes_new_[a-z]+/)
      .datepicker(
        altFormat: "yy-mm-dd",
        dateFormat: "yy-mm-dd",
        minDate: "-0d",
        showOtherMonths: true,
        selectOtherMonths: true
      )

  bindDatepicker()

  $('form').bind 'nested:fieldAdded', ->
    bindDatepicker()
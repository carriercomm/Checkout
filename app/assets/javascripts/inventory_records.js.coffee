jQuery ->
  $('#inventory_records_shortcuts')
    .removeClass('hidden')
    .find('.inventory_record_shortcut')
    .click (e) ->
      console.log('clicked')
      value = $(this).data('value')
      $('select').val(value)
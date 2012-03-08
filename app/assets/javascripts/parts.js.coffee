jQuery ->
  models = $('#part_model_id').html()

  set_select = ->
    brand = $('#part_model_attributes_brand_id :selected').text()
    escaped_brand = brand.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1')
    #options = $(models).filter("optgroup[label='#{escaped_brand}']").append('<option style="color: #00F;">&lt;New...&gt;</option>"').html()
    options = $(models).filter("optgroup[label='#{escaped_brand}']").html()
    if options
      $('#part_model_id').html(options)
      $('#part_model_id').parent().show()
    else
      $('#part_model_id').empty()
      $('#part_model_id').parent().hide()

  if $('#part_model_attributes_brand_id :selected').text() == ""
    $('#part_model_id').parent().hide()
  else
    set_select()

  $('#part_model_attributes_brand_id').change ->
    set_select()



jQuery ->

  # reset the forms when we show a modal
  $('[href|="#brand_modal"], [href|="#budget_modal"], [href|="#category_modal"], [href|="#location_modal"]').bind 'click', ->
    $('.alert-error').addClass('hide')
    $('.error-message').html('')
    $('.modal-form input, .modal-form textarea')
      .not('[name|="authenticity_token"]')
      .not('[name|="utf8"]')
      .not('[type|="submit"]')
      .val('')
    $('input[type|="submit"]').removeAttr('disabled')

  # reset the form when we show the modal
  $('.modal_submit').bind 'click', ->
    $(this).attr('disabled', 'disabled')
    $(this).parents('form').submit()

  # Parse the JSON response and generate an unordered list of errors, then stick it inside
  # <div class="errors"> which is in our view template
  $('form.modal-form').on 'ajax:error', (event, xhr, status, error) ->
    # parse the response to extract the errors
    responseObject = $.parseJSON(xhr.responseText)
    # get a handle to the alert box
    errors = $('.error-message')
    # clear out any old errors
    errors.html('')
    # add the error messages to the alert box
    $.each responseObject, (index, value) ->
      errors.append('<div>' + titleCaps(index) + ' ' + value + '</div>')
    # show the alert box
    $('.alert-error').removeClass('hide')
    # make sure the submit button works
    $('input[type|="submit"]').removeAttr('disabled')


  #
  # Brand Modal Form
  #

  # Parse the JSON response and update the form with the successfully created category
  $('form.new-brand').on 'ajax:success', (event, data, status, xhr) ->
    # temporarily destroy the tokenized select box
    $('.select2-json-autocomplete').select2("val", {id: data.id, text: data.text})
    # hide the modal
    $("#brand_modal").modal('hide')

  #
  # Budget Modal Form
  #

  # Parse the JSON response and update the form with the successfully created budget
  $('form.new-budget').on 'ajax:success', (event, data, status, xhr) ->
    # add our new budget, as a selected option
    $(".budget-select").append('<option value="' + data.id + '" selected>' + data.name + '</option>')
    # hide the modal
    $("#budget_modal").modal('hide')

  #
  # Category Modal Form
  # 

  # Parse the JSON response and update the form with the successfully created category
  $('form.new-category').on 'ajax:success', (event, data, status, xhr) ->
    # temporarily destroy the tokenized select box
    $('.select2-tagged-field.categories-select').select2("destroy")
    # add our new category, as a selected option
    $(".categories-select").append('<option value="' + data.id + '" selected>' + data.name + '</option>')
    # recreate the tokenized select box
    $('.select2-tagged-field.categories-select').select2()
    # hide the modal
    $("#category_modal").modal('hide')
  
  #
  # Location Modal Form
  #

  # Parse the JSON response and update the form with the successfully created location
  $('form.new-location').on 'ajax:success', (event, data, status, xhr) ->
    # add our new location, as a selected option
    $(".location-select").append('<option value="' + data.id + '" selected>' + data.name + '</option>')
    # hide the modal
    $("#location_modal").modal('hide')


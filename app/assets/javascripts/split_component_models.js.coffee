jQuery ->
  bindFormSwitcher = ->
    # look for the radio button and bind to its change event
    $('div[data-toggle="form-switcher"] input').bind 'change', ->
      _this = $(this)
      parent = _this.closest(".fields")

      # alter the radio buttons so they're in a new group
      name = Math.ceil(Math.random() * 1000000) + "_radio"
      parent.find("div[data-toggle=form-switcher] input[type=radio]").attr("name", name)

      # show the one we want
      if "new" == _this.data('field-type')
        parent.find(".existing-model").addClass("hidden")
        parent.find(".new-model").removeClass("hidden")
      else
        parent.find(".existing-model").removeClass("hidden")
        parent.find(".new-model").addClass("hidden")

  # call once on page load
  bindFormSwitcher()

  # call each time a nested component is added to the form
  $('form').bind 'nested:fieldAdded', ->
    bindFormSwitcher()

  # remove the hidden parts of the form from the DOM before we submit
  $('form.split-component-model').submit ->
    $('.new-model.hidden').remove()
    $('.existing-model.hidden').remove()
jQuery ->
  $('form').bind 'nested:fieldAdded', ->
    $('div[data-toggle="form-switcher"] input').bind 'change', ->
      _this = $(this)
      parent = _this.closest(".fields")

      # show the one we want
      if "new" == _this.data('field-type')
        parent.find(".existing-model").addClass("hidden")
        parent.find(".new-model").removeClass("hidden")
      else
        parent.find(".existing-model").removeClass("hidden")
        parent.find(".new-model").addClass("hidden")

  $('form.split-component-model').submit ->
    $('.new-model.hidden').remove()
    $('.existing-model.hidden').remove()
jQuery ->

  #
  # AJAX widget
  #

  formatAjaxResult = (item) ->
    markup = "<table class='item-result'><tr>"
    markup += "<td class='item-info'><div class='item-name'>" + item.text + "</div>"
    markup += "</td></tr></table>"
    return markup

  formatAjaxSelection = (item) ->
    return item.text

  ajaxConfig =
    minimumInputLength: 1
    width: 'element'
    ajax:
      crossDomain: false
      dataType: 'json'
      data: (term, page) ->
        rtn_val =
          q: term
          page_limit: 10
        return rtn_val
      # parse the results into the format expected by Select2.
      results: (data, page) ->
        # determine whether or not there are more results available
        more = (page * 10) < data.total;
        # since we are using custom formatting functions we do not need to alter remote JSON data
        results =
          results: data.items
          more: more
        return results
    formatResult: formatAjaxResult
    formatSelection: formatAjaxSelection
    initSelection: (element, callback) ->
      id = element.val()
      text = element.data('text');
      callback({id: id, text: text})

  #
  # JSON Autocomplete Field
  #

  bindJsonAutocomplete = ->
    $('input.select2-json-autocomplete')
      .select2("destroy")
      # .filter ->
      #   return !this.id.match(/[a-z_]+_attributes_new_[a-z]+/);
      # .not('.select2-bound')
      # .addClass('select2-bound')
      # .select2(ajaxConfig)
      .bind 'change', (e) ->
        me = $(this)
        me.data("text", me.select2("data").text)
      .each ->
        $(this).select2($.extend(true, {}, ajaxConfig))    

  # call it
  bindJsonAutocomplete()


  #
  # Tagged Field
  # 

  # make sure the select2 widget binds to any new nested components added to the form
  $('form').bind 'nested:fieldAdded', ->
    bindJsonAutocomplete()
    $('.select2-tagged-field')
      .select2("destroy")
      .select2()

  $('.select2-tagged-field').select2()

  #
  # Form Switcher helper
  #

  $('form').bind 'form-switcher:existing-shown', (e) ->
    debugger
    $(e.target).find(".existing-component-model input.select-model").select2(ajaxConfig)

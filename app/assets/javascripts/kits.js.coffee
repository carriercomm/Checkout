jQuery ->
  modelFormatResult = (model) ->
    markup = "<table class='model-result'><tr>"
    markup += "<td class='model-info'><div class='model-name'>" + model.text + "</div>"
    markup += "</td></tr></table>"
    return markup

  modelFormatSelection = (model) ->
    return model.text

  select2Config =
    placeholder:
      title: "Search for a model"
      id: ""
    minimumInputLength: 1
    # TODO: figure out how to move this width to a stylesheet
    width:'220px'
    ajax:
      crossDomain: false
      url: "/models.json"
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
          results: data.models
          more: more
        return results
    formatResult: modelFormatResult
    formatSelection: modelFormatSelection

  # make sure the select2 widget binds to any new nested components added to the form
  $('form').bind 'nested:fieldAdded', ->
    # FIXME: ARRRgghhh!! This is awful.
    $('input.select2-json-autocomplete').not('#kit_components_attributes_new_components_model_id').not('.select2-bound').addClass('select2-bound').select2(select2Config)

  # bind the select2 widget to existing nested components in the form
  $('input.select2-json-autocomplete').not('#kit_components_attributes_new_components_model_id').not('.select2-bound').addClass('select2-bound').select2(select2Config)
  

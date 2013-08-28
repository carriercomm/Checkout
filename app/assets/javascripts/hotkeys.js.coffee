key '/', ->
  $('#q').focus()
  return false
key 'f1', ->
  $('#shortcuts_modal').modal('toggle')

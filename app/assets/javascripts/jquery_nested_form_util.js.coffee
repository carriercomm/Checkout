jQuery ->
  # this is a utility method to delay execution of code until some
  # dependencies are loaded - e.g. from an external script
  $.fn.executeWhenLoaded = (func, args...) ->
    intRef = null
    executeCheck = ->
      for arg in args
        if (! window[arg])
          if (!intRef) then intRef = setInterval(executeCheck, 50)
          return
      clearInterval(intRef)
      func()
    executeCheck()

  # this monkeypatches the nested form javascript to support nested
  # forms in tables
  window.monkeyPatchNestedForm = ->
    window.NestedFormEvents.prototype.insertFields = (content, assoc, link) ->
      $tr = $(link).closest('tr')
      $(content).insertBefore($tr)
  
  $('.form-table').executeWhenLoaded(window.monkeyPatchNestedForm, 'NestedFormEvents')

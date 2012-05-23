class WindowUtil
  @addOnload: (func) ->
    try
      window.addEventListener('load', func, false)
    catch ex
      # for IE
      window.attachEvent('onload', func)

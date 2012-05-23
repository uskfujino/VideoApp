class MessageHandler
  #constructor: () ->
  @showDebugMessage: (message) ->
    console.log message
    $('#debugDisplay').get(0).style.display='inline'
    $('#debugDisplayMessage').text(message)

  @showWarning: (message) ->
    $('#warningDisplay').get(0).style.display='inline'
    $('#warningDisplayMessage').text(message)

  @showError: (message) ->
    $('#errorDisplay').get(0).style.display='inline'
    $('#errorDisplayMessage').text(message)


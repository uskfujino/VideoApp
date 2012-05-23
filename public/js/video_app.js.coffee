class VideoApp
  constructor: () ->
    try
      canvas = document.getElementById('videoScreen')
      @ctx = canvas.getContext('2d')
      @cw = 500
      @ch = 300
      canvas.width = @cw
      canvas.height = @ch
      @ctx.fillStyle = 'rgb(0, 0, 0)'
      @ctx.strokeRect(0, 0, @cw, @ch)
    catch ex
      MessageHandler.showError ex

  initChannel: (pusherKey, channelId) ->
    try
      if !channelId
        MessageHandler.showWarning 'Channel ID is empty'
        return

      MessageHandler.showDebugMessage 'channelId = ' + channelId

      @pusher = new Pusher(pusherKey)
      @channel = @pusher.subscribe('private-' + channelId)
      @channel.bind('pusher:subscription_succeeded', () ->
        MessageHandler.showDebugMessage 'videoApp pusher:subscription_successed'
      )
      @channel.bind('pusher:subscription_error', (status) ->
        MessageHandler.showDebugMessage 'videoApp pusher:subscription_error' + status
      )
      @channel.bind('client-hello', (data) -> alert data)

      parent = this 

      sendImageCallback = (data) ->
        try
          MessageHandler.showDebugMessage 'sendImage callback called'
          parent.show data
        catch ex
          MessageHandler.showError 'sendImage callback ' + ex

      @channel.bind('client-sendImage', sendImageCallback)

      @channel.bind('client-show', (data) -> parent.show(data))
    catch ex
      MessageHandler.showDebugMessage ex

  deleteChannel: (pusherKey, channelId) ->
    #Send Delete Ajax Request

  show: (imageSrc) ->
    try
      parent = this 
      image = new Image()
      image.onload = () ->
        try
          parent.ctx.drawImage(this, 0, 0)
        catch ex
          MessageHandler.showDebugMessage 'image.onload ' + ex
  
      image.src = imageSrc
    catch ex
      MessageHandler.showDebugMessage 'videoApp.show ' + ex
      throw ex

# run app
#$(() -> videoApp = new VideoApp())


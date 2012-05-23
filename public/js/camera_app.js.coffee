class CameraApp
  #Methods
  constructor: () ->
    try
      return unless @createVideo()

      @canvas = document.getElementById('cameraScreen')
      @ctx = @canvas.getContext('2d')
      @cw = 500
      @ch = 300
      @canvas.width = @cw
      @canvas.height = @ch
      @ctx.fillStyle = 'rgb(0, 0, 0)'
      @ctx.strokeRect(0, 0, @cw, @ch)
      @isBroadcasting = false
      @fps = 2
      MessageHandler.showDebugMessage 'CameraApp initialized'
    catch ex
      MessageHandler.showError 'Cannot start camera. Please retry.'
      MessageHandler.showDebugMessage 'CameraApp() : ' + ex

  createVideo: () ->
    try
      @video = $('#camera').get(0)

      parent = this

      successCallback = () ->
        try
          MessageHandler.showDebugMessage 'CameraApp.video callback called.'
          parent.draw()
        catch e
          MessageHandler.showError 'Cannot play video. Please retry.'
          MessageHandler.showDebugMessage 'CameraApp.video callback failed.'

      @video.addEventListener 'play', successCallback

      if navigator.webkitGetUserMedia
        navigator.webkitGetUserMedia("video", (stream) ->
          parent.video.src = window.webkitURL.createObjectURL(stream)
        )
        true
      else if navigator.getUserMedia
        navigator.getUserMedia("audio, video", (stream) ->
          parent.video.src = stream
        )
        true
      else
        MessageHandler.showWarning 'Your bouser does not support camera function'
        false
    catch ex
      MessageHandler.showError 'Cannot start camera. Please retry.'
      MessageHandler.showDebugMessage 'CameraApp.createVideo : ' + ex
      false

  mirrorHorizontally: () ->
    @ctx.translate(@cw, 0)
    @ctx.scale(-1, 1)

  show: (image) ->
    try
      @ctx.drawImage(image, 0, 0, @cw, @ch)
    catch ex
      MessageHandler.showError 'Cannot show camera image. Please retry.'
      MessageHandler.showDebugMessage 'CameraApp.show ' + ex

  snap: () ->
    try
      @show(@video)
  
      if @channel
        @channel.trigger('client-show', @canvas.toDataURL())
    catch ex
      MessageHandler.showError 'Cannot snap camera image. Please retry.'
      MessageHandler.showDebugMessage 'CameraApp.snap ' + ex

  draw: () ->
    try
      @snap()
      if @fps > 0
        callback = () -> @draw()
        setTimeout(callback.bind(this), 1000 / @fps)
    catch ex
      MessageHandler.showError 'Cannot draw camera image. Please retry.'
      MessageHandler.showDebugMessage 'CameraApp.draw ' + ex

  changeBroadcastState: (pusherKey, channelId) ->
    try
      if @isBroadcasting
        @stopBroadcast(channelId)
      else
        @startBroadcast(pusherKey, channelId)
      true
    catch ex
      MessageHandler.showError 'Cannot start/stop broadcasting. Please retry.'
      MessageHandler.showDebugMessage 'CameraApp.changeBroadcastState ' + ex

  startBroadcast: (pusherKey, channelId) ->
    try 
      MessageHandler.showDebugMessage 'Channel ID : ' + channelId + ', Pusher Key : ' + pusherKey
      if @pusher
        @stopBroadcast()
      @pusher = new Pusher(pusherKey)
      @channel = @pusher.subscribe('private-' + channelId)
      @channel.bind('pusher:subscription_succeeded', () ->
        MessageHandler.showDebugMessage 'cameraApp pusher:subscription_successed'
      )
      @channel.bind('pusher:subscription_error', (status) ->
        MessageHandler.showDebugMessage 'cameraApp pusher:subscription_error' + status
      )
      @channel.bind('client-hello', (data) -> alert data)
      @channel.bind('client-getVideo', (data) -> @sendVideo())
      @isBroadcasting = true
    catch ex
      MessageHandler.showDebugMessage 'cameraApp.startBroadcast ' + ex
      MessageHandler.showError 'Cannot start broadcasting. Please retry.'

  stopBroadcast: (channelId) ->
    try
      MessageHandler.showDebugMessage 'cameraApp.stopBroadcast called'
      if @isBroadcasting
        MessageHandler.showDebugMessage 'cameraApp.stopBroadcast called 2'
        @pusher.unsubscribe('private-' + channelId)
        @isBroadcasting = false
        
        #@video.pause()
    catch ex
      MessageHandler.showDebugMessage 'cameraApp.stopBroadcast ' + ex
      MessageHandler.showError 'Cannot stop broadcasting. Please retry.'

#  class Debugger
#    hello: (cameraApp) ->
#      try
#        cameraApp.channel.trigger('client-hello', 'hello world')
#      catch ex
#        MessageHandler.showError ex
#        
#    sendImage: (cameraApp) ->
#      try
#        alert 'sendImage before toDataURL'
#        image = cameraApp.canvas.toDataURL()
#        cameraApp.channel.trigger('client-sendImage', image)
#      catch ex
#        MessageHandler.showError 'sendImage ' + ex

# run app
#$(() -> )


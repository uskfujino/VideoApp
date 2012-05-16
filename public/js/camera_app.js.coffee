class MessageHandler
  constructor: () ->

  showDebugMessage: (message) ->
    console.log message
    $('#debugDisplay').get(0).style.display='inline'
    $('#debugDisplayMessage').text(message)

  showWarning: (message) ->
    $('#warningDisplay').get(0).style.display='inline'
    $('#warningDisplayMessage').text(message)

  showError: (message) ->
    $('#errorDisplay').get(0).style.display='inline'
    $('#errorDisplayMessage').text(message)

messageHandler = new MessageHandler()

class CameraApp
  #Attributes
  #canvas: {}
  #video: {}
  #ctx: {}
  #cw: 0
  #ch: 0
  #isBroadcasting: false
  #pusher: {}
  #channel: null

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
      messageHandler.showDebugMessage 'CameraApp initialized'
    catch ex
      messageHandler.showError 'Cannot start camera. Please retry.'
      messageHandler.showDebugMessage 'CameraApp() : ' + ex

  createVideo: () ->
    try
      @video = $('#camera').get(0)

      parent = this

      successCallback = () ->
        try
          messageHandler.showDebugMessage 'CameraApp.video callback called.'
          parent.draw()
        catch e
          messageHandler.showError 'Cannot play video. Please retry.'
          messageHandler.showDebugMessage 'CameraApp.video callback failed.'

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
        messageHandler.showWarning 'Your bouser does not support camera function'
        false
    catch ex
      messageHandler.showError 'Cannot start camera. Please retry.'
      messageHandler.showDebugMessage 'CameraApp.createVideo : ' + ex
      false

  mirrorHorizontally: () ->
    @ctx.translate(@cw, 0)
    @ctx.scale(-1, 1)

  show: (image) ->
    try
      @ctx.drawImage(image, 0, 0, @cw, @ch)
    catch ex
      messageHandler.showError 'Cannot show camera image. Please retry.'
      messageHandler.showDebugMessage 'CameraApp.show ' + ex

  snap: () ->
    try
      @show(@video)
  
      if @channel
        @channel.trigger('client-show', @canvas.toDataURL())
    catch ex
      messageHandler.showError 'Cannot snap camera image. Please retry.'
      messageHandler.showDebugMessage 'CameraApp.snap ' + ex

  draw: () ->
    try
      @snap()
      parent = this
      callback = () -> parent.draw()
      setTimeout(callback, 1000)
    catch ex
      messageHandler.showError 'Cannot draw camera image. Please retry.'
      messageHandler.showDebugMessage 'CameraApp.draw ' + ex

  changeBroadcastState: (pusherKey, channelId) ->
    try
      if @isBroadcasting
        @stopBroadcast(channelId)
      else
        @startBroadcast(pusherKey, channelId)
      true
    catch ex
      messageHandler.showError 'Cannot start/stop broadcasting. Please retry.'
      messageHandler.showDebugMessage 'CameraApp.changeBroadcastState ' + ex

  startBroadcast: (pusherKey, channelId) ->
    try 
      messageHandler.showDebugMessage 'Channel ID : ' + channelId + ', Pusher Key : ' + pusherKey
      if @pusher
        @stopBroadcast()
      @pusher = new Pusher(pusherKey)
      @channel = @pusher.subscribe('private-' + channelId)
      @channel.bind('pusher:subscription_succeeded', () ->
        messageHandler.showDebugMessage 'cameraApp pusher:subscription_successed'
      )
      @channel.bind('pusher:subscription_error', (status) ->
        messageHandler.showDebugMessage 'cameraApp pusher:subscription_error' + status
      )
      @channel.bind('client-hello', (data) -> alert data)
      @channel.bind('client-getVideo', (data) -> @sendVideo())
      @isBroadcasting = true
    catch ex
      messageHandler.showDebugMessage 'cameraApp.startBroadcast ' + ex
      messageHandler.showError 'Cannot start broadcasting. Please retry.'

  stopBroadcast: (channelId) ->
    try
      messageHandler.showDebugMessage 'cameraApp.stopBroadcast called'
      if @isBroadcasting
        messageHandler.showDebugMessage 'cameraApp.stopBroadcast called 2'
        @pusher.unsubscribe('private-' + channelId)
        @isBroadcasting = false
        
        #@video.pause()
    catch ex
      messageHandler.showDebugMessage 'cameraApp.stopBroadcast ' + ex
      messageHandler.showError 'Cannot stop broadcasting. Please retry.'

#  class Debugger
#    hello: (cameraApp) ->
#      try
#        cameraApp.channel.trigger('client-hello', 'hello world')
#      catch ex
#        messageHandler.showError ex
#        
#    sendImage: (cameraApp) ->
#      try
#        alert 'sendImage before toDataURL'
#        image = cameraApp.canvas.toDataURL()
#        cameraApp.channel.trigger('client-sendImage', image)
#      catch ex
#        messageHandler.showError 'sendImage ' + ex

# run app
#$(() -> )


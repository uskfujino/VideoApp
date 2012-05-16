class MessageHandler
  constructor: () ->

  showWarning: (message) ->
    $('#warningDisplay').get(0).style.display='inline'
    $('#warningDisplayMessage').text(message)

  showError: (message) ->
    $('#errorDisplay').get(0).style.display='inline'
    $('#errorDisplayMessage').text(message)

messageHandler = new MessageHandler()

cameraApp = {
  canvas: {}
  ctx: {}
  video: {}
  cw: 0
  ch: 0
  initialize: () -> alert('initialize not defined')
  mirrorHorizontally: () -> alert('mirrorHorizontally not defined')  
  show: (image) -> alert('show not defined')
  snap: () -> alert('snap not defined')
  draw: () -> alert('draw not defined')
  isBroadcasting: false
  startBroadcast: (pusherKey, channelId) -> alert('startBroadcast not defined')
  stopBroadcast: (channelId) -> alert('stopBroadcast not defined')
  pusher: {}
  channel: null
  debugger: {}
}

cameraApp.initialize = () ->
  try
    video = $('video').get(0)

    if navigator.webkitGetUserMedia
      navigator.webkitGetUserMedia("video", (stream) ->
        url = window.webkitURL.createObjectURL(stream)
        video.src = url
      )
    else if navigator.getUserMedia
      navigator.getUserMedia("audio, video", (stream) ->
        video.src = stream
      )
    else
      #alert 'Your bouser does not support camera function'
      messageHandler.showWarning 'Your bouser does not support camera function'
      return
    
    canvas = document.getElementById('cameraScreen')
    ctx = canvas.getContext('2d')
    #cw = Math.floor(canvas.clientWidth / 100)
    #ch = Math.floor(canvas.clientHeight / 100)
    cw = 500
    ch = 300
    canvas.width = cw
    canvas.height = ch
    ctx.fillStyle = 'rgb(0, 0, 0)'
    ctx.strokeRect(0, 0, cw, ch)

    video.addEventListener 'play', (e) -> cameraApp.draw()

    cameraApp.canvas = canvas
    cameraApp.video = video
    cameraApp.ctx = ctx
    cameraApp.cw = cw
    cameraApp.ch = ch
  
  catch ex
    alert(ex)

cameraApp.mirrorHorizontally = () ->
  cameraApp.ctx.translate(cameraApp.cw, 0)
  cameraApp.ctx.scale(-1, 1)

cameraApp.show = (image) ->
  try
    cameraApp.ctx.drawImage(image, 0, 0, cameraApp.cw, cameraApp.ch)
  catch ex
    alert 'cameraApp.show ' + ex

cameraApp.snap = () ->
  try
    cameraApp.show(cameraApp.video)

    if cameraApp.channel
      cameraApp.channel.trigger('client-show', cameraApp.canvas.toDataURL())
  catch ex
    alert 'cameraApp.snap ' + ex

cameraApp.draw = () ->
  try
    cameraApp.snap()
    setTimeout(cameraApp.draw, 1000)
    #setTimeout(cameraApp.draw, 20)
  catch ex
    alert 'cameraApp.draw ' + ex

cameraApp.startBroadcast = (pusherKey, channelId) ->
  try 
    alert 'Channel ID : ' + channelId + ', Pusher Key : ' + pusherKey
    cameraApp.stopBroadcast()
    cameraApp.pusher = new Pusher(pusherKey)
    cameraApp.channel = cameraApp.pusher.subscribe('private-' + channelId)
    cameraApp.channel.bind('pusher:subscription_succeeded', () ->
      alert 'cameraApp pusher:subscription_successed'
    )
    cameraApp.channel.bind('pusher:subscription_error', (status) ->
      alert 'cameraApp pusher:subscription_error' + status
    )
    cameraApp.channel.bind('client-hello', (data) -> alert data)
    cameraApp.channel.bind('client-getVideo', (data) -> cameraApp.sendVideo())
    cameraApp.isBroadcasting = true
  catch ex
    alert 'cameraApp.startBroadcast ' + ex

cameraApp.stopBroadcast = (channelId) ->
  try
    alert 'cameraApp.stopBroadcast called'
    if cameraApp.isBroadcasting
      alert 'cameraApp.stopBroadcast called 2'
      cameraApp.pusher.unsubscribe('private-' + channelId)
      cameraApp.isBroadcasting = false
    #cameraApp.video.src.stop()
  catch ex
    alert 'cameraApp.stopBroadcast ' + ex

cameraApp.debugger = {
  hello: () ->
    try
      cameraApp.channel.trigger('client-hello', 'hello world')
    catch ex
      alert ex
      
  sendImage: () ->
    try
      alert 'sendImage before toDataURL'
      image = cameraApp.canvas.toDataURL()
      cameraApp.channel.trigger('client-sendImage', image)
    catch ex
      alert 'sendImage ' + ex
} 

# run app
$(() -> cameraApp.initialize())


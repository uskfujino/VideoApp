videoApp = {
  ctx: {}
  cw: 0
  ch: 0
  initialize: () -> alert('initialize not defined')
  show: (image) -> alert('show not defined')
  initChannel: (pusherKey) -> alert('initChannel not defined')
  pusher: {}
  channel: null
  video: null
  reader: {}
}

videoApp.initialize = () ->
  try
    canvas = document.getElementById('videoScreen')
    ctx = canvas.getContext('2d')
    cw = 500
    ch = 300
    canvas.width = cw
    canvas.height = ch
    ctx.fillStyle = 'rgb(0, 0, 0)'
    ctx.strokeRect(0, 0, cw, ch)

    videoApp.ctx = ctx
    videoApp.cw = cw
    videoApp.ch = ch

  catch ex
    alert(ex)

videoApp.initChannel = (pusherKey) ->
  try
    channelId = document.getElementById('channelId').value
    if !channelId
      alert 'Channel ID is empty'
      return

    alert 'channelId = ' + channelId

    videoApp.pusher = new Pusher(pusherKey)
    videoApp.channel = videoApp.pusher.subscribe('private-' + channelId)
    videoApp.channel.bind('pusher:subscription_succeeded', () ->
      alert 'videoApp pusher:subscription_successed'
    )
    videoApp.channel.bind('pusher:subscription_error', (status) ->
      alert 'videoApp pusher:subscription_error' + status
    )
    videoApp.channel.bind('client-hello', (data) -> alert data)
    videoApp.channel.bind('client-sendImage', (data) ->
      try
        alert 'sendImage callback called'
        videoApp.show(data)
      catch ex
        alert 'sendImage callback ' + ex
    )
    videoApp.channel.bind('client-show', (data) -> 
      videoApp.show(data)
    )
  catch ex
    alert ex

videoApp.show = (imageSrc) ->
  try
    image = new Image()
    image.onload = () ->
      try
        videoApp.ctx.drawImage(this, 0, 0)
      catch ex
        alert 'image.onload ' + ex

    image.src = imageSrc
  catch ex
    alert 'videoApp.show ' + ex
    throw ex

# run app
$(() -> videoApp.initialize())


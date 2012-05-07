cameraApp = {
  ctx: {}
  video: {}
  cw: 0
  ch: 0
  initialize: () -> alert('initialize not defined')
  mirrorHorizontally: () -> alert('mirrorHorizontally not defined')  
  snap: () -> alert('snap not defined')
  draw: () -> alert('draw not defined')
}

cameraApp.initialize = () ->
  try
    if !navigator.getUserMedia
      alert('Your bouser does not support camera function')
      return
    
    video = $('video').get(0)

    successCallBack = (stream) ->
      cameraApp.video.src = stream
    
    navigator.getUserMedia('video', successCallBack)

    canvas = document.getElementById('screen')
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

    cameraApp.video = video
    cameraApp.ctx = ctx
    cameraApp.cw = cw
    cameraApp.ch = ch
  
  catch ex
    alert(ex)

cameraApp.mirrorHorizontally = () ->
  cameraApp.ctx.translate(cameraApp.cw, 0)
  cameraApp.ctx.scale(-1, 1)

cameraApp.snap = () ->
  try
    cameraApp.ctx.drawImage(cameraApp.video, 0, 0, cameraApp.cw, cameraApp.ch)
  catch ex
    alert(ex)

cameraApp.draw = () ->
  try
    cameraApp.snap()
    setTimeout(cameraApp.draw, 20)
  catch ex
    alert(ex)

# run app
$(() -> cameraApp.initialize())


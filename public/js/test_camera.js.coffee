ctx = 0
video = 0
cw = 0
ch = 0

$(
  () ->
    try
      if !navigator.getUserMedia
        alert('Your bouser does not support camera function')
        return
      
      video = $('video').get(0)

      successCallBack = (stream) ->
        video.src = stream
      
      navigator.getUserMedia('video', successCallBack)

      canvas = document.getElementById('screen')
      ctx = canvas.getContext('2d')
      #cw = Math.floor(canvas.clientWidth / 100)
      #ch = Math.floor(canvas.clientHeight / 100)
      cw = 400
      ch = 200
      canvas.width = cw
      canvas.height = ch
      ctx.fillStyle = 'rgb(0, 0, 0)'
      ctx.strokeRect(0, 0, cw, ch)

      #mirrorHorizontally()

      video.addEventListener 'play', (e) -> draw()
    
    catch ex
      alert(ex)
)

mirrorHorizontally = () ->
  ctx.translate(cw, 0)
  ctx.scale(-1, 1)

snap = () ->
  try
    ctx.drawImage(video, 0, 0, cw, ch)
  catch ex
    alert(ex)

draw = () ->
  try
    snap()
    setTimeout(draw, 20)
  catch ex
    alert(ex)


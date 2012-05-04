try
  SIZE = 4.5
  WIDTH = 300
  HEIGHT = 150
  
  canvas = ''
  ctx = ''
  eraser = 'rgb(255, 255, 255)'
  defaultPen = 'rgb(0, 0, 0)'
  mouseDown = false
  
  initCanvas = () ->
    canvas = document.getElementById('canvas')
    ctx = canvas.getContext('2d')
    canvas.width = window.innerWidth = WIDTH
    canvas.height = window.innerHeight = HEIGHT
    canvas.onmousemove = onMouseMove
    canvas.onmousedown = onMouseDown
    canvas.onmouseup = onMouseUp
    canvas.onmouseout = onMouseOut
    clearCanvas()

  window.onload = () -> initCanvas()

  clearCanvas = () ->
    ctx.beginPath()
    ctx.fillStyle = eraser 
    ctx.fillRect(0, 0, WIDTH, HEIGHT)
    ctx.fillStyle = defaultPen
    ctx.strokeRect(0, 0, WIDTH, HEIGHT)
  
  onMouseMove = (e) ->
    if !mouseDown
      return

    rect = e.target.getBoundingClientRect()
    mouseX = e.clientX - rect.left
    mouseY = e.clientY - rect.top
    ctx.beginPath()
    ctx.fillStyle = defaultPen
    #ctx.fillStyle = 'rgb(255, 255, 255)'
    ctx.fillRect(mouseX - SIZE / 2, mouseY - SIZE / 2, SIZE, SIZE)
    ctx.fill()

  onMouseDown = (e) ->
    mouseDown = true

  onMouseUp = (e) ->
    mouseDown = false

  onMouseOut = (e) ->
    mouseDown = false

catch ex
  alert(ex)

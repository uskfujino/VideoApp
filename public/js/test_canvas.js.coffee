canvasApp = {
  frontCanvas: {}
  backCanvas: {}
  frontCtx: {}
  backCtx: {}
  init: () -> alert 'init not defined'
  clear: () -> alert 'clear not defined'
  onMouseMove: (e) -> alert 'onMouseMove not defined'
  onMouseDown: (e) -> alert 'onMouseDown not defined'
  onMouseUp: (e) -> alert 'onMouseUp not defined'
  onMouseOut: (e) -> alert 'onMouseOut not defined'
  mouseDown: false
}

$(() ->
  try
    SIZE = 4.5
    WIDTH = 300
    HEIGHT = 150
    ERASER = 'rgb(255, 255, 255)'
    
    defaultPen = 'rgb(0, 0, 0)'
    
    canvasApp.init = () ->
      try
        frontCanvas = document.getElementById('front_canvas')
        canvasApp.frontCtx = frontCanvas.getContext('2d')
        frontCanvas.width = window.innerWidth = WIDTH
        frontCanvas.height = window.innerHeight = HEIGHT
        frontCanvas.onmousemove = canvasApp.onMouseMove
        frontCanvas.onmousedown = canvasApp.onMouseDown
        frontCanvas.onmouseup = canvasApp.onMouseUp
        frontCanvas.onmouseout = canvasApp.onMouseOut
        canvasApp.frontCanvas = frontCanvas

        backCanvas = document.getElementById('back_canvas')
        canvasApp.backCtx = backCanvas.getContext('2d')
        backCanvas.width = window.innerWidth = WIDTH
        backCanvas.height = window.innerHeight = HEIGHT
        canvasApp.backCanvas = backCanvas

        canvasApp.clear()
      catch ex
        alert 'canvasApp.init exception ' + ex
      
    canvasApp.clear = () ->
      try
        frontCtx = canvasApp.frontCtx
        frontCtx.beginPath()
        frontCtx.fillStyle = ERASER 
        frontCtx.fillRect(0, 0, WIDTH, HEIGHT)
        frontCtx.fillStyle = defaultPen
        frontCtx.strokeRect(0, 0, WIDTH, HEIGHT)
      catch ex
        alert 'canvasApp.clear ' + ex
  
    canvasApp.onMouseMove = (e) ->
      try
        if !canvasApp.mouseDown
          return
  
        rect = e.target.getBoundingClientRect()
        mouseX = e.clientX - rect.left
        mouseY = e.clientY - rect.top
        frontCtx = canvasApp.frontCtx
        frontCtx.beginPath()
        frontCtx.fillStyle = defaultPen
        #frontCtx.fillStyle = 'rgb(255, 255, 255)'
        frontCtx.fillRect(mouseX - SIZE / 2, mouseY - SIZE / 2, SIZE, SIZE)
        frontCtx.fill()
      catch ex
        alert 'canvasApp.onMouseMove ' + ex
  
    canvasApp.onMouseDown = (e) ->
      try
        canvasApp.mouseDown = true
      catch ex
        alert 'canvasApp.onMouseDown ' + ex
  
    canvasApp.onMouseUp = (e) ->
      canvasApp.mouseDown = false
  
    canvasApp.onMouseOut = (e) ->
      canvasApp.mouseDown = false
  
  catch ex
    alert(ex)
)

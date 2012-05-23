class CanvasApp
  constructor: () ->
    try
      @SIZE = 4.5
      @WIDTH = 300
      @HEIGHT = 150
      @ERASER = 'rgb(255, 255, 255)'
      @DEFAULT_PEN  = 'rgb(0, 0, 0)'

      #@frontCanvas = document.getElementById('front_canvas')
      @frontCanvas = $('#front_canvas').get(0)
      @frontCanvas.width = window.innerWidth = @WIDTH
      @frontCanvas.height = window.innerHeight = @HEIGHT
      @frontCanvas.onmousemove = @onMouseMove.bind(this)
      @frontCanvas.onmousedown = @onMouseDown.bind(this)
      @frontCanvas.onmouseup = @onMouseUp.bind(this)
      @frontCanvas.onmouseout = @onMouseOut.bind(this)
      @frontCtx = @frontCanvas.getContext('2d')
      @frontCtx.font = '20pt Arial'

      #@backCanvas = document.getElementById('back_canvas')
      @backCanvas = $('#back_canvas').get(0)
      @backCtx = @backCanvas.getContext('2d')
      @backCtx.font = '20pt Arial'
      @backCanvas.width = window.innerWidth = @WIDTH
      @backCanvas.height = window.innerHeight = @HEIGHT

      @clear()
      @mouseDown = false
    catch ex
      MessageHandler.showError 'CanvasApp constructor exception ' + ex

  clear: () ->
    try
      MessageHandler.showDebugMessage 'CameraApp.clear called'
      @frontCtx.beginPath()
      @frontCtx.fillStyle = @ERASER 
      @frontCtx.fillRect(0, 0, @WIDTH, @HEIGHT)
      @frontCtx.fillStyle = @DEFAULT_PEN
      @frontCtx.strokeRect(0, 0, @WIDTH, @HEIGHT)
    catch ex
      MessageHandler.showError 'canvasApp.clear ' + ex

  onMouseMove: (e) ->
    try
      if !@mouseDown
        return
  
      rect = e.target.getBoundingClientRect()
      mouseX = e.clientX - rect.left
      mouseY = e.clientY - rect.top
      @frontCtx.beginPath()
      @frontCtx.fillStyle = @DEFAULT_PEN
      @frontCtx.fillRect(mouseX - @SIZE / 2, mouseY - @SIZE / 2, @SIZE, @SIZE)
      @frontCtx.fill()
    catch ex
      MessageHandler.showError 'canvasApp.onMouseMove ' + ex
  
  onMouseDown: (e) ->
    try
      @mouseDown = true
    catch ex
      MessageHandler.showError 'canvasApp.onMouseDown ' + ex
  
  onMouseUp: (e) ->
    @mouseDown = false
  
  onMouseOut: (e) ->
    @mouseDown = false

  changeFps: () ->
    try
      fps = $('#fps').get(0)

      if fps > 0
        @fps = fps
      else
        MessageHandler.showError 'FPS must be greater than 0'
    catch ex
      MessageHandler.showError 'CameraApp.changeFps ' + ex

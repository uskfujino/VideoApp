class CanvasEditor
  constructor: (@app) ->
    try
      @frontCtx = @app.frontCtx
      @backCtx = @app.backCtx
    catch ex
      MessageHandler.showError 'CanvasEditor constructor ' + ex

  comment: (comment) ->
    try
      if @frontCtx && @backCtx
        @moveText(comment, 50, 50, 0, 50, -1, 0)
    catch ex
      MessageHandler.showError 'canvasEditor.comment ' + ex
  
  moveText: (txt, sx, sy, ex, ey, dx, dy) ->
    try
      xExceed = () ->
        (dx > 0) ? sx > ex : sx < ex
  
      yExceed = () ->
        (dy > 0) ? sy > ey : sy < ey
        
      if xExceed() || yExceed()
        MessageHandler.showDebugMessage 'exceed'
        return
  
      @clear @frontCtx
      @frontCtx.fillText(txt, sx, sy)
      callback = () -> @moveText(txt, sx + dx, sy + dy, ex, ey, dx, dy)
      setTimeout(callback.bind(this), 20)
    catch e
      MessageHandler.showError 'canvasEditor.moveText ' + e
  
  clear: (ctx) ->
    try
      ERASER = 'rgb(255, 255, 255)'
      ctx.beginPath()
      beforeStyle = ctx.fillStyle
      ctx.fillStyle = ERASER 
      ctx.fillRect(0, 0, ctx.width, ctx.height)
      ctx.fillStyle = beforeStyle
    catch ex
      MessageHandler.showError 'canvasEditor.clear ' + ex
  
  copyImage: (from, to) ->
    try
      to.putImageData(from.getImageData(0, 0, from.width, from.height))
    catch ex
      MessageHandler.showError 'canvasEditor.copyImage ' + ex

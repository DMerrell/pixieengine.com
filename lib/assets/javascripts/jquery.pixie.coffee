#= require color_util
#= require undo_stack

(($) ->
  track = (action, label) ->
    trackEvent?("Pixel Editor", action, label)

  DEBUG = false

  DIV = "<div />"
  IMAGE_DIR = "/assets/pixie/"
  RGB_PARSER = /^rgba?\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3}),?\s*(\d\.?\d*)?\)$/
  scale = 1

  palette = [
    "#000000", "#FFFFFF", "#666666", "#DCDCDC", "#EB070E"
    "#F69508", "#FFDE49", "#388326", "#0246E3", "#563495"
    "#58C4F5", "#E5AC99", "#5B4635", "#FFFEE9"
  ]

  falseFn = -> return false

  primaryButton = (event) ->
    !event.button? || event.button == 0

  ColorPicker = ->
    $('<input/>',
      class: 'color'
    ).colorPicker()

  actions =
    undo:
      hotkeys: ['ctrl+z', 'meta+z']
      perform: (canvas) ->
        canvas.undo()
      undoable: false
    redo:
      hotkeys: ["ctrl+y", "meta+z"]
      perform: (canvas) ->
        canvas.redo()
      undoable: false
    clear:
      perform: (canvas) ->
        canvas.eachPixel (pixel) ->
          pixel.color(Color().toString(), false, "replace")
    preview:
      menu: false
      perform: (canvas) ->
        canvas.preview()
      undoable: false
    left:
      hotkeys: ["left"]
      menu: false
      perform: `function(canvas) {
        var deferredColors = [];

        canvas.height.times(function(y) {
          deferredColors[y] = canvas.getPixel(0, y).color();
        });

        canvas.eachPixel(function(pixel, x, y) {
          var rightPixel = canvas.getPixel(x + 1, y);

          if(rightPixel) {
            pixel.color(rightPixel.color(), false, 'replace');
          } else {
            pixel.color(Color(), false, 'replace')
          }
        });

        $.each(deferredColors, function(y, color) {
          canvas.getPixel(canvas.width - 1, y).color(color);
        });
      }`
    right:
      hotkeys: ["right"]
      menu: false
      perform: `function(canvas) {
        var width = canvas.width;
        var height = canvas.height;

        var deferredColors = [];

        height.times(function(y) {
          deferredColors[y] = canvas.getPixel(width - 1, y).color();
        });

        for(var x = width-1; x >= 0; x--) {
          for(var y = 0; y < height; y++) {
            var currentPixel = canvas.getPixel(x, y);
            var leftPixel = canvas.getPixel(x - 1, y);

            if(leftPixel) {
              currentPixel.color(leftPixel.color(), false, 'replace');
            } else {
              currentPixel.color(Color(), false, 'replace');
            }
          }
        }

        $.each(deferredColors, function(y, color) {
          canvas.getPixel(0, y).color(color);
        });
      }`
    up:
      hotkeys: ["up"]
      menu: false
      perform: `function(canvas) {
        var deferredColors = [];

        canvas.width.times(function(x) {
          deferredColors[x] = canvas.getPixel(x, 0).color();
        });

        canvas.eachPixel(function(pixel, x, y) {
          var lowerPixel = canvas.getPixel(x, y + 1);

          if(lowerPixel) {
            pixel.color(lowerPixel.color(), false, 'replace');
          } else {
            pixel.color(Color(), false, 'replace');
          }
        });

        $.each(deferredColors, function(x, color) {
          canvas.getPixel(x, canvas.height - 1).color(color);
        });
      }`
    down:
      hotkeys: ["down"]
      menu: false
      perform: `function(canvas) {
        var width = canvas.width;
        var height = canvas.height;

        var deferredColors = [];

        canvas.width.times(function(x) {
          deferredColors[x] = canvas.getPixel(x, height - 1).color();
        });

        for(var x = 0; x < width; x++) {
          for(var y = height-1; y >= 0; y--) {
            var currentPixel = canvas.getPixel(x, y);
            var upperPixel = canvas.getPixel(x, y-1);

            if(upperPixel) {
              currentPixel.color(upperPixel.color(), false, 'replace');
            } else {
              currentPixel.color(Color(), false, 'replace');
            }
          }
        }

        $.each(deferredColors, function(x, color) {
          canvas.getPixel(x, 0).color(color);
        });
      }`
    download:
      hotkeys: ["ctrl+s"]
      perform: (canvas) ->
        w = window.open()
        w.document.location = canvas.toDataURL()
      undoable: false

  colorNeighbors = (color) ->
    this.color(color)
    $.each this.canvas.getNeighbors(this.x, this.y), (i, neighbor) ->
      neighbor?.color(color)

  line = (canvas, color, p0, p1) ->
    {x:x0, y:y0} = p0
    {x:x1, y:y1} = p1

    dx = (x1 - x0).abs()
    dy = (y1 - y0).abs()
    sx = (x1 - x0).sign()
    sy = (y1 - y0).sign()
    err = dx - dy

    canvas.getPixel(x0, y0).color(color)

    while !(x0 == x1 and y0 == y1)
      canvas.getPixel(x0, y0).color(color)

      e2 = 2 * err

      if e2 > -dy
        err -= dy
        x0 += sx

      if e2 < dx
        err += dx
        y0 += sy

    canvas.getPixel(x0, y0).color(color)

  pencilTool = ( ->
    lastPosition = Point(0, 0)

    cursor: "url(" + IMAGE_DIR + "pencil.png) 4 14, default"
    hotkeys: ['p', '1']
    mousedown: (e, color) ->
      currentPosition = Point(@x, @y)

      if e.shiftKey
        line(@canvas, color, lastPosition, currentPosition)
      else
        this.color(color)

      lastPosition = currentPosition
    mouseenter: (e, color) ->
      currentPosition = Point(@x, @y)
      line(@canvas, color, lastPosition, currentPosition)
      lastPosition = currentPosition
  )()

  erase = (pixel, opacity) ->
    inverseOpacity = (1 - opacity)
    pixelColor = pixel.color()

    pixel.color(Color(pixelColor.toString(), pixelColor.a * inverseOpacity), false, "replace")

  tools =
    pencil: pencilTool

    mirror_pencil:
      cursor: "url(" + IMAGE_DIR + "mirror_pencil.png) 8 14, default"
      hotkeys: ['m']
      mousedown: (e, color) ->
        canvas = this.canvas
        mirrorCoordinate = canvas.width - this.x - 1
        this.color(color)
        this.canvas.getPixel(mirrorCoordinate, this.y).color(color)
      mouseenter: (e, color) ->
        canvas = this.canvas
        mirrorCoordinate = canvas.width - this.x - 1
        this.color(color)
        this.canvas.getPixel(mirrorCoordinate, this.y).color(color)
    brush:
      cursor: "url(" + IMAGE_DIR + "brush.png) 4 14, default"
      hotkeys: ['b', '2']
      mousedown: (e, color) ->
        colorNeighbors.call(this, color)
      mouseenter: (e, color) ->
        colorNeighbors.call(this, color)
    dropper:
      cursor: "url(" + IMAGE_DIR + "dropper.png) 13 13, default"
      hotkeys: ['i', '3']
      mousedown: ->
        this.canvas.color(this.color())
        this.canvas.setTool(tools.pencil)
      mouseup: ->
        this.canvas.setTool(tools.pencil)
    eraser:
      cursor: "url(" + IMAGE_DIR + "eraser.png) 4 11, default"
      hotkeys: ['e', '4']
      mousedown: (e, color, pixel) ->
        erase(pixel, color.a)
      mouseenter: (e, color, pixel) ->
        erase(pixel, color.a)
    fill:
      cursor: "url(" + IMAGE_DIR + "fill.png) 12 13, default"
      hotkeys: ['f', '5']
      mousedown: (e, newColor, pixel) ->
        originalColor = this.color()
        return if newColor.equal(originalColor)

        q = []
        pixel.color(newColor)
        q.push(pixel)

        canvas = this.canvas

        while(q.length)
          pixel = q.pop()

          neighbors = canvas.getNeighbors(pixel.x, pixel.y)

          $.each neighbors, (index, neighbor) ->
            if neighbor?.color().equal(originalColor)
              neighbor.color(newColor)
              q.push(neighbor)

  debugTools =
    inspector:
      mousedown: ->
        console.log(this.color())

  $.fn.pixie = (options) ->
    Pixel = (x, y, layerCanvas, canvas, undoStack) ->
      color = Color()

      redraw = () ->
        xPos = x * PIXEL_WIDTH
        yPos = y * PIXEL_HEIGHT

        layerCanvas.clearRect(xPos, yPos, PIXEL_WIDTH, PIXEL_HEIGHT)
        layerCanvas.fillStyle = color.toString()
        layerCanvas.fillRect(xPos, yPos, PIXEL_WIDTH, PIXEL_HEIGHT)

      self =
        canvas: canvas

        redraw: redraw

        color: (newColor, skipUndo, blendMode) ->
          if arguments.length >= 1
            blendMode ||= "additive"

            oldColor = Color(color)

            color = ColorUtil[blendMode](Color(oldColor), Color(newColor))

            redraw()

            undoStack.add(self, {pixel: self, oldColor: oldColor, newColor: color}) unless skipUndo

            return self
          else
            Color(color)

        toString: -> "[Pixel: " + [this.x, this.y].join(",") + "]"
        x: x
        y: y

      return self

    Layer = ->
      layer = $ "<canvas />",
        class: "layer"

      gridColor = "#000"
      layerWidth = -> width * PIXEL_WIDTH
      layerHeight = -> height * PIXEL_HEIGHT
      layerElement = layer.get(0)
      layerElement.width = layerWidth()
      layerElement.height = layerHeight()

      context = layerElement.getContext("2d")

      return $.extend layer,
        clear: ->
          context.clearRect(0, 0, layerWidth(), layerHeight())

        context: context

        drawGuide: ->
          context.fillStyle = gridColor
          height.times (row) ->
            context.fillRect(0, (row + 1) * PIXEL_HEIGHT, layerWidth(), 1)

          width.times (col) ->
            context.fillRect((col + 1) * PIXEL_WIDTH, 0, 1, layerHeight())

        resize: () ->
          layerElement.width = layerWidth()
          layerElement.height = layerHeight()

    options ||= {}

    width = parseInt(options.width || 8, 10)
    height = parseInt(options.height || 8, 10)
    initializer = options.initializer
    PIXEL_WIDTH = parseInt(options.pixelWidth || options.pixelSize || 16, 10)
    PIXEL_HEIGHT = parseInt(options.pixelHeight || options.pixelSize || 16, 10)

    return this.each ->
      pixie = $(this).addClass("editor pixie")

      content = $ DIV,
        class: 'content'

      viewport = $ DIV,
        class: 'viewport'

      canvas = $ DIV,
        class: 'canvas'
        width: width * PIXEL_WIDTH + 2
        height: height * PIXEL_HEIGHT + 2

      toolbar = $ DIV,
        class: 'toolbar'

      swatches = $ DIV,
        class: 'swatches'

      colorbar = $ DIV,
        class: 'toolbar'

      actionbar = $ DIV,
        class: 'actions'

      navRight = $("<nav class='right module'></nav>")
      navLeft = $("<nav class='left module'></nav>")

      opacityVal = $ DIV,
        class: "val"
        text: 100

      opacitySlider = $(DIV, class: "opacity").slider(
        orientation: 'vertical'
        value: 100
        min: 5
        max: 100
        step: 5
        slide: (event, ui) ->
          opacityVal.text(ui.value)
      ).append(opacityVal)

      opacityVal.text(opacitySlider.slider('value'))

      tilePreview = true

      preview = $ DIV,
        class: 'preview'
        style: "width: #{width}px; height: #{height}px"

      preview.mousedown ->
        tilePreview = !tilePreview

        canvas.preview()

        track('mousedown', 'preview')

      currentTool = undefined
      active = false
      mode = undefined
      undoStack = UndoStack()
      primaryColorPicker = ColorPicker().addClass('primary')
      secondaryColorPicker = ColorPicker().addClass('secondary')
      replaying = false
      initialStateData = undefined

      colorPickerHolder = $(DIV,
        class: 'color_picker_holder'
      ).append(primaryColorPicker, secondaryColorPicker)

      colorbar.append(colorPickerHolder, swatches)

      pixie
        .bind('contextmenu', falseFn)
        .bind('mouseup', (e) ->
          active = false
          mode = undefined

          canvas.preview()
        )

      $(document).bind 'keyup', ->
        canvas.preview()

      $(navRight).bind 'mousedown touchstart', (e) ->
        target = $(e.target)

        if target.is('.swatch')
          color = Color(target.css('backgroundColor'))
          canvas.color(color, !primaryButton(e))

          track(e.type, color.toString())

      pixels = []

      lastPixel = undefined

      handleEvent = (event, element) ->
        opacity = opacityVal.text() / 100

        offset = element.offset()

        local =
          y: event.pageY - offset.top
          x: event.pageX - offset.left

        row = Math.floor(local.y / PIXEL_HEIGHT)
        col = Math.floor(local.x / PIXEL_WIDTH)

        pixel = canvas.getPixel(col, row)
        eventType = undefined

        if (event.type == "mousedown") || (event.type == "touchstart")
          eventType = "mousedown"
        else if pixel && pixel != lastPixel && (event.type == "mousemove" || event.type == "touchmove")
          eventType = "mouseenter"

        if pixel && active && currentTool && currentTool[eventType]
          c = canvas.color().toString()

          currentTool[eventType].call(pixel, event, Color(c, opacity), pixel)

        lastPixel = pixel

      layer = Layer()
      guideLayer = Layer()
        .bind("mousedown touchstart", (e) ->
          #TODO These triggers aren't perfect like the `dirty` method that queries.
          pixie.trigger('dirty')
          undoStack.next()
          active = true
          if primaryButton(e)
            mode = "P"
          else
            mode = "S"

          e.preventDefault()
        )
        .bind("mousedown mousemove", (event) ->
          handleEvent event, $(this)
        )
        .bind("touchstart touchmove", (e) ->
          # NOTE: global event object
          Array::each.call event.touches, (touch) =>
            touch.type = e.type
            handleEvent touch, $(this)
        )

      layers = [layer, guideLayer]

      height.times (row) ->
        pixels[row] = []

        width.times (col) ->
          pixel = Pixel(col, row, layer.get(0).getContext('2d'), canvas, undoStack)
          pixels[row][col] = pixel

      canvas.append(layer, guideLayer)

      $.extend canvas,
        addAction: (action) ->
          name = action.name
          titleText = name.capitalize()
          undoable = action.undoable

          doIt = ->
            if undoable != false
              pixie.trigger('dirty')
              undoStack.next()

            action.perform(canvas)

          if action.hotkeys
            titleText += " (#{action.hotkeys}) "

            $.each action.hotkeys, (i, hotkey) ->
              #TODO Add action hokey json data

              $(document).bind 'keydown', hotkey, (e) ->
                if currentComponent == pixie
                  e.preventDefault()
                  doIt()

                  track('hotkey', action.name)

                  return false

          if action.menu != false
            iconImg = $ "<img />",
              src: action.icon || IMAGE_DIR + name + '.png'

            actionButton = $("<a />",
              class: 'tool button'
              title: titleText
              text: name.capitalize()
            )
            .prepend(iconImg)
            .bind "mousedown touchstart", (e) ->
              doIt() unless $(this).attr('disabled')

              # These currently get covered by the global link click tracking
              # track(e.type, action.name)

              return false

            actionButton.appendTo(actionbar)

        addSwatch: (color) ->
          swatches.append $ DIV,
            class: 'swatch'
            style: "background-color: #{color.toString()}"

        addTool: (tool) ->
          name = tool.name
          alt = name.capitalize()

          tool.icon ||= IMAGE_DIR + name + '.png'

          setMe = ->
            canvas.setTool(tool)
            toolbar.children().removeClass("active")
            toolDiv.addClass("active")

          if tool.hotkeys
            alt += " (" + tool.hotkeys + ")"

            $.each tool.hotkeys, (i, hotkey) ->
              $(document).bind 'keydown', hotkey, (e) ->
                #TODO Generate tool hotkeys json data

                if currentComponent == pixie
                  e.preventDefault()
                  setMe()

                  track("hotkey", tool.name)

                  return false

          img = $ "<img />",
            src: tool.icon
            alt: alt
            title: alt

          toolDiv = $("<div class='tool'></div>")
            .append(img)
            .bind("mousedown touchstart", (e) ->
              setMe()

              track(e.type, tool.name)

              return false
            )

          toolbar.append(toolDiv)

        color: (color, alternate) ->
          if (arguments.length == 0 || color == false)
            if mode == "S"
              return Color(secondaryColorPicker.css('backgroundColor'))
            else
              return Color(primaryColorPicker.css('backgroundColor'))
          else if color == true
            if mode == "S"
              Color(primaryColorPicker.css('backgroundColor'))
            else
              Color(secondaryColorPicker.css('backgroundColor'))

          if (mode == "S") ^ alternate
            secondaryColorPicker.val(color.toHex().substr(1))
            secondaryColorPicker[0].onblur()
          else
            primaryColorPicker.val(color.toHex().substr(1))
            primaryColorPicker[0].onblur()

          return this

        clear: -> layer.clear()

        dirty: (newDirty) ->
          if newDirty != undefined
            if newDirty == false
              lastClean = undoStack.last()
            return this
          else
            return lastClean != undoStack.last()

        displayInitialState: (stateData) ->
          this.clear()

          stateData ||= initialStateData

          if stateData
            $.each stateData, (f, data) ->
              canvas.eachPixel (pixel, x, y) ->
                pos = x + y*canvas.width
                pixel.color(Color(data[pos]), true, "replace")

        eachPixel: (fn) ->
          height.times (row) ->
            width.times (col) ->
              pixel = pixels[row][col]
              fn.call(pixel, pixel, col, row)

          canvas

        eval: (code) ->
          eval(code)

        fromDataURL: (dataURL) ->
          context = document.createElement('canvas').getContext('2d')

          image = new Image()
          image.onload = ->
            if image.width * image.height < 128 * 96
              canvas.resize(image.width, image.height)

              context.drawImage(image, 0, 0)
              imageData = context.getImageData(0, 0, image.width, image.height)

              getColor = (x, y) ->
                index = (x + y * imageData.width) * 4

                return Color(imageData.data[index + 0], imageData.data[index + 1], imageData.data[index + 2], imageData.data[index + 3] / 255)

              canvas.eachPixel (pixel, x, y) ->
                pixel.color(getColor(x, y), true)
            else
              alert("This image is too big for our editor to handle, try 96x96 and smaller")

            return

          image.src = dataURL

        getColor: (x, y) ->
          context = layer.context
          imageData = context.getImageData(x * PIXEL_WIDTH, y * PIXEL_HEIGHT, 1, 1)

          return Color(imageData.data[0], imageData.data[1], imageData.data[2], imageData.data[3] / 255)

        getNeighbors: (x, y) ->
          return [
            this.getPixel(x+1, y)
            this.getPixel(x, y+1)
            this.getPixel(x-1, y)
            this.getPixel(x, y-1)
          ]

        getPixel: (x, y) ->
          return pixels[y][x] if (0 <= y < height) && (0 <= x < width)
          return undefined

        getReplayData: -> undoStack.replayData()

        toHex: (bits) ->
          s = parseInt(bits).toString(16)
          if s.length == 1
            s = '0' + s

          return s

        preview: ->
          tileCount = if tilePreview then 4 else 1

          preview.css
            backgroundImage: this.toCSSImageURL()
            width: tileCount * width
            height: tileCount * height

        redo: ->
          data = undoStack.popRedo()

          if data
            pixie.trigger("dirty")

            $.each data, ->
              this.pixel.color(this.newColor, true, "replace")

        replay: (steps, parentData) ->
          unless replaying
            replaying = true
            canvas = this

            if !steps
              steps = canvas.getReplayData()
              canvas.displayInitialState()
            else
              if parentData
                canvas.displayInitialState(parentData)
              else
                canvas.clear()

            i = 0
            delay = (5000 / steps.length).clamp(1, 200)

            runStep = ->
              step = steps[i]

              if step
                $.each step, (j, p) ->
                  canvas.getPixel(p.x, p.y).color(p.color, true, "replace")

                i++

                setTimeout(runStep, delay)
              else
                replaying = false

            setTimeout(runStep, delay)

        resize: (newWidth, newHeight) ->
          this.width = width = newWidth
          this.height = height = newHeight

          pixels = pixels.slice(0, newHeight)

          pixels.push [] while pixels.length < newHeight

          pixels.each (row, y) ->
            row.pop() while row.length > newWidth
            row.push Pixel(row.length, y, layer.get(0).getContext('2d'), canvas, undoStack) while row.length < newWidth

          layers.each (layer) ->
            layer.clear()
            layer.resize()

          canvas.css
            width: width * PIXEL_WIDTH + 2
            height: height * PIXEL_HEIGHT + 2

          pixels.each (row) ->
            row.each (pixel) ->
              pixel.redraw()

        setInitialState: (frameData) ->
          initialStateData = frameData

          this.displayInitialState()

        setTool: (tool) ->
          currentTool = tool
          canvas.css('cursor', tool.cursor || "pointer")

        toBase64: (f) ->
          data = this.toDataURL(f)
          return data.substr(data.indexOf(',') + 1)

        toCSSImageURL: -> "url(#{this.toDataURL()})"

        toDataURL: ->
          tempCanvas = $("<canvas width=#{width} height=#{height}></canvas>").get(0)

          context = tempCanvas.getContext('2d')

          this.eachPixel (pixel, x, y) ->
            color = pixel.color()
            context.fillStyle = color.toString()
            context.fillRect(x, y, 1, 1)

          return tempCanvas.toDataURL("image/png")

        undo: ->
          data = undoStack.popUndo()

          if data
            pixie.trigger("dirty")

            $.each data, ->
              this.pixel.color(this.oldColor, true, "replace")

        width: width
        height: height

      $.each tools, (key, tool) ->
        tool.name = key
        canvas.addTool(tool)

      if DEBUG
        $.each debugTools, (key, tool) ->
          tool.name = key
          canvas.addTool(tool)

      $.each actions, (key, action) ->
        action.name = key
        canvas.addAction(action)

      $.each palette, (i, color) ->
        canvas.addSwatch(Color(color))

      canvas.setTool(tools.pencil)

      viewport.append(canvas)

      $(navLeft).append(toolbar)
      $(navRight).append(colorbar, preview, opacitySlider)
      content.append(actionbar, viewport, navLeft, navRight)
      pixie.append(content)

      pixie.bind 'mouseenter', ->
        window.currentComponent = pixie

      pixie.bind 'touchstart touchmove touchend', ->
        event.preventDefault()

      window.currentComponent = pixie

      if initializer
        initializer(canvas)

      lastClean = undoStack.last()
)(jQuery)

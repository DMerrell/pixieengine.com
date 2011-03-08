(($) ->
  DIV = "<div />"
  IMAGE_DIR = "/images/pixie/"
  RGB_PARSER = /^rgba?\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3}),?\s*(\d\.?\d*)?\)$/
  scale = 1

  palette = [
    "#000000", "#FFFFFF", "#666666", "#DCDCDC", "#EB070E"
    "#F69508", "#FFDE49", "#388326", "#0246E3", "#563495"
    "#58C4F5", "#E5AC99", "#5B4635", "#FFFEE9"
  ]

  falseFn = -> return false

  ColorPicker = ->
    $('<input/>',
      class: 'color'
    ).colorPicker()

  UndoStack = ->
    undos = []
    redos = []
    empty = true

    last: -> undos[undos.length - 1]

    popUndo: ->
      undo = undos.pop()

      redos.push(undo) if undo

      return undo

    popRedo: ->
      redo = redos.pop()

      undos.push(redo) if redo

      return redo

    next: ->
      last = this.last()
      if !last || !empty
        undos.push({})
        empty = true

        redos = []

    add: (object, data) ->
      last = this.last()

      if last[object]
        last[object].newColor = data.newColor
      else
        last[object] = data
        empty = false


      return this

    replayData: ->
      replayData = []

      $.each undos, (i, items) ->
        replayData[i] = []
        $.each items, (key, data) ->
          pixel = data.pixel
          replayData[i].push
            x: pixel.x
            y: pixel.y
            color: data.newColor

      return replayData

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
          pixel.color(Color(0, 0, 0, 0), false, true)
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
            pixel.color(rightPixel.color(), false, true);
          } else {
            pixel.color(Color(0, 0, 0, 0), false, true)
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
              currentPixel.color(leftPixel.color(), false, true);
            } else {
              currentPixel.color(Color(0, 0, 0, 0), false, true);
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
            pixel.color(lowerPixel.color(), false, true);
          } else {
            pixel.color(Color(0, 0, 0, 0), false, true);
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
              currentPixel.color(upperPixel.color(), false, true);
            } else {
              currentPixel.color(Color(0, 0, 0, 0), false, true);
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
    options:
      hotkeys: ["o"]
      perform: ->
        $('#optionsModal').removeAttr('style').modal(
          persist: true
          ,
          onClose: ->
            $.modal.close()
            $('#optionsModal').attr('style', 'display: none')
        )

  colorNeighbors = (color) ->
    this.color(color)
    $.each this.canvas.getNeighbors(this.x, this.y), (i, neighbor) ->
      neighbor?.color(color)

  erase = (pixel, opacity) ->
    inverseOpacity = (1 - opacity)
    pixelColor = pixel.color()

    pixel.color(Color(pixelColor, pixelColor.opacity() * inverseOpacity), false, true)

  tools =
    pencil:
      cursor: "url(" + IMAGE_DIR + "pencil.png) 4 14, default"
      hotkeys: ['p', '1']
      mousedown: (e, color) ->
        this.color(color)
      mouseenter: (e, color) ->
        this.color(color)
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
        erase(pixel, color.opacity())
      mouseenter: (e, color, pixel) ->
        erase(pixel, color.opacity())
    fill:
      cursor: "url(" + IMAGE_DIR + "fill.png) 12 13, default"
      hotkeys: ['f', '5']
      mousedown: (e, newColor, pixel) ->
        originalColor = this.color()
        return if newColor.equals(originalColor)

        q = []
        pixel.color(newColor)
        q.push(pixel)

        canvas = this.canvas

        while(q.length)
          pixel = q.pop()

          neighbors = canvas.getNeighbors(pixel.x, pixel.y)

          $.each neighbors, (index, neighbor) ->
            if neighbor?.color().equals(originalColor)
              neighbor.color(newColor)
              q.push(neighbor)

  $.fn.pixie = (options) ->
    tilePreview = true
    Pixel = (x, y, layerCanvas, canvas, undoStack) ->
      color = Color(0, 0, 0, 0)

      self =
        canvas: canvas

        color: (newColor, skipUndo, replace) ->
          if arguments.length >= 1
            oldColor = color

            xPos = x * PIXEL_WIDTH
            yPos = y * PIXEL_HEIGHT

            if replace
              layerCanvas.clearRect(xPos, yPos, PIXEL_WIDTH, PIXEL_HEIGHT)
            layerCanvas.fillStyle = newColor.toString()
            layerCanvas.fillRect(xPos, yPos, PIXEL_WIDTH, PIXEL_HEIGHT)

            color = canvas.getColor(x, y)

            undoStack.add(self, {pixel: self, oldColor: oldColor, newColor: color}) unless skipUndo

            return self
          else
            color

        toString: -> "[Pixel: " + [this.x, this.y].join(",") + "]"
        x: x
        y: y

      return self

    Layer = ->
      layer = $ "<canvas />",
        class: "layer"

      gridColor = "#000"
      layerWidth = width * PIXEL_WIDTH
      layerHeight = height * PIXEL_HEIGHT
      layerElement = layer.get(0)
      layerElement.width = layerWidth
      layerElement.height = layerHeight

      context = layerElement.getContext("2d")

      return $.extend layer,
        clear: ->
          context.clearRect(0, 0, layerWidth, layerHeight)
        context: context
        drawGuide: ->
          context.fillStyle = gridColor
          height.times (row) ->
            context.fillRect(0, (row + 1) * PIXEL_HEIGHT, layerWidth, 1)

          width.times (col) ->
            context.fillRect((col + 1) * PIXEL_WIDTH, 0, 1, layerHeight)

    PIXEL_WIDTH = 16
    PIXEL_HEIGHT = 16

    options ||= {}

    width = options.width || 8
    height = options.height || 8
    initializer = options.initializer

    return this.each ->
      pixie = $ DIV,
        class: 'pixie'

      viewport = $ DIV,
        class: 'viewport'

      canvas = $ DIV,
        class: 'canvas'
        style: "width: #{(width * PIXEL_WIDTH) + 2}px; height: #{(height * PIXEL_HEIGHT) + 2}px;"

      toolbar = $ DIV,
        class: 'toolbar'

      swatches = $ DIV,
        class: 'swatches'

      colorbar = $ DIV,
        class: 'toolbar'

      actionbar = $ DIV,
        class: 'actions'

      navRight = $("<nav class='right'></nav>")
      navLeft = $("<nav class='left'></nav>")

      opacityVal = $("<div id=opacity_val>100</div>")

      opacitySlider = $(DIV,
        id: 'opacity'
      ).slider(
        orientation: 'vertical'
        value: 100
        min: 0
        max: 100
        slide: (event, ui) ->
          $('#opacity_val').text(ui.value)
      ).append(opacityVal)

      $('#opacity_val').text($('#opacity').slider('value'))

      preview = $ DIV,
        class: 'preview'
        style: "width: #{width}px; height: #{height}px"

      previewToggleHolder = $ DIV,
        class: 'toggle_holder'

      previewToggle = $('<input checked="true" class="preview_control" type="checkbox" />').change ->
        if $(this).attr('checked')
          tilePreview = true
        else
          tilePreview = false

        canvas.preview()

      previewLabel = $('<label class="preview_control">Tiled Preview</label>').click ->
        if previewToggle.attr('checked')
          previewToggle.removeAttr('checked')
          tilePreview = false
        else
          previewToggle.attr('checked', 'true')
          tilePreview = true

        canvas.preview()

      guideToggleHolder = $ DIV,
        class: 'toggle_holder'

      guideLabel = $("<label class='guide_control'>Display Guides</label>").click ->

        if guideToggle.attr('checked')
          guideToggle.removeAttr('checked')
          guideLayer.clear()
          $('.canvas').css('border', '1px solid transparent')
        else
          guideToggle.attr('checked', 'true')
          guideLayer.drawGuide()
          $('.canvas').css('border', '1px solid black')

      guideToggle = $('<input class="guide_control" type="checkbox"></input>').change ->
        if $(this).attr('checked')
          guideLayer.drawGuide()
          $('.canvas').css('border', '1px solid black')
        else
          guideLayer.clear()
          $('.canvas').css('border', '1px solid transparent')

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

      $(navRight).bind 'mousedown', (e) ->
        target = $(e.target)
        color = Color.parse(target.css('backgroundColor'))

        canvas.color(color, e.button != 0) if target.is('.swatch')

      pixels = []

      lastPixel = undefined
      layer = Layer()
        .bind("mousedown", (e) ->
          undoStack.next()
          active = true
          if e.button == 0 then mode = "P" else mode = "S"

          e.preventDefault()
        )
        .bind("mousedown mousemove", (event) ->
          opacity = $('#opacity_val').text() / 100
          offset = $(this).offset()

          localY = event.pageY - offset.top
          localX = event.pageX - offset.left

          row = Math.floor(localY / PIXEL_HEIGHT)
          col = Math.floor(localX / PIXEL_WIDTH)

          pixel = canvas.getPixel(col, row)
          eventType = undefined

          if event.type == "mousedown"
            eventType = event.type
          else if pixel && pixel != lastPixel && event.type == "mousemove"
            eventType = "mouseenter"

          if pixel && active && currentTool && currentTool[eventType]
            currentTool[eventType].call(pixel, event, Color(canvas.color(), opacity), pixel)

          lastPixel = pixel
        )

        guideLayer = Layer()

      height.times (row) ->
        pixels[row] = []

        width.times (col) ->
          pixel = Pixel(col, row, layer.get(0).getContext('2d'), canvas, undoStack)
          pixels[row][col] = pixel

      canvas.append(layer, guideLayer)

      $.extend canvas,
        addAction: (name, action) ->
          titleText = name.capitalize()
          undoable = action.undoable

          doIt = ->
            undoStack.next() if undoable != false
            action.perform(canvas)

          if action.hotkeys
            titleText += " (#{action.hotkeys}) "

            $.each action.hotkeys, (i, hotkey) ->
              $(document).bind 'keydown', hotkey, (e) ->
                doIt()
                e.preventDefault()

                false

          if action.menu != false
            iconImg = $ "<img />",
              src: action.icon || IMAGE_DIR + name + '.png'

            actionButton = $("<a />",
              class: 'tool button'
              title: titleText
              text: name.capitalize()
            )
            .prepend(iconImg)
            .mousedown (e) ->
              doIt() unless $(this).attr('disabled')

              _gaq.push(['_trackEvent', 'action_button', action.name])

              return false

            actionButton.appendTo(actionbar)

        addSwatch: (color) ->
          swatches.append $ DIV,
            class: 'swatch'
            style: "background-color: #{color.toString()}"

        addTool: (name, tool) ->
          alt = name.capitalize()

          tool.name = name
          tool.icon = IMAGE_DIR + name + '.png'

          setMe = ->
            canvas.setTool(tool)
            toolbar.children().removeClass("active")
            toolDiv.addClass("active")

          if tool.hotkeys
            alt += " (" + tool.hotkeys + ")"

            $.each tool.hotkeys, (i, hotkey) ->
              $(document).bind 'keydown', hotkey, (e) ->
                setMe()
                e.preventDefault()

          img = $ "<img />",
            src: tool.icon
            alt: alt
            title: alt

          toolDiv = $("<div class='tool'></div>")
            .append(img)
            .mousedown (e) ->
              setMe()
              return false

          toolbar.append(toolDiv)

        color: (color, alternate) ->
          if (arguments.length == 0 || color == false)
            return (if mode == "S" then Color.parse(secondaryColorPicker.css('backgroundColor')) else Color.parse(primaryColorPicker.css('backgroundColor')))
          else if color == true
            return (if mode == "S" then Color.parse(primaryColorPicker.css('backgroundColor')) else Color.parse(secondaryColorPicker.css('backgroundColor')))

          if (mode == "S") ^ alternate
            secondaryColorPicker.val(color)
            secondaryColorPicker[0].onblur()
          else
            primaryColorPicker.val(color)
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

        displayInitialState: ->
          this.clear()

          if initialStateData
            $.each initialStateData, (f, data) ->
              canvas.eachPixel (pixel, x, y) ->
                pos = x + y*canvas.width
                pixel.color(data[pos], true)

        eachPixel: (fn) ->
          height.times (row) ->
            width.times (col) ->
              pixel = pixels[row][col]
              fn.call(pixel, pixel, col, row)

          canvas

        fromDataURL: (dataURL) ->
          context = document.createElement('canvas').getContext('2d')

          image = new Image()
          image.onload = ->
            context.drawImage(image, 0, 0)
            imageData = context.getImageData(0, 0, image.width, image.height)

            getColor = (x, y) ->
              index = (x + y * imageData.width) * 4

              return Color(imageData.data[index + 0], imageData.data[index + 1], imageData.data[index + 2], imageData.data[index + 3] / 255).rgba()

            canvas.eachPixel (pixel, x, y) ->
              pixel.color(getColor(x, y), true)

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
            $.each data, ->
              this.pixel.color(this.newColor, true, true)

        replay: (steps) ->
          unless replaying
            replaying = true
            canvas = this

            if !steps
              steps = canvas.getReplayData()
              canvas.displayInitialState()
            else
              canvas.clear()

            i = 0
            delay = (5000 / steps.length).clamp(1, 200)

            runStep = ->
              step = steps[i]

              if step
                $.each step, (j, p) ->
                  canvas.getPixel(p.x, p.y).color(p.color, true, true)

                i++

                setTimeout(runStep, delay)
              else
                replaying = false

            setTimeout(runStep, delay)

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
            $.each data, ->
              this.pixel.color(this.oldColor, true, true)

        width: width
        height: height

      $.each tools, (key, tool) ->
        canvas.addTool(key, tool)

      $.each actions, (key, action) ->
        canvas.addAction(key, action)

      $.each palette, (i, color) ->
        canvas.addSwatch(Color(color))

      canvas.setTool(tools.pencil)

      viewport.append(canvas)
      previewToggleHolder.append(previewToggle, previewLabel)
      guideToggleHolder.append(guideToggle, guideLabel)
      $('#optionsModal').append(guideToggleHolder, previewToggleHolder)

      $(navLeft).append(toolbar)
      $(navRight).append(colorbar, preview, opacitySlider)
      pixie.append(actionbar, viewport, navLeft, navRight)
      $(this).append(pixie)

      if initializer
        initializer(canvas)

      lastClean = undoStack.last()
)(jQuery)
window.createPixelEditor = (options) ->
  {panel, path, mtime} = options

  dataUrl = "/production/projects/#{projectId}/#{path}?#{mtime}"
  _canvas = null

  editorOptions = $.extend panel.data("options"),
    frames: 1
    initializer: (canvas) ->
      _canvas = canvas

      if contentsVal = panel.find("[name=contents]").val()
        canvas.fromDataURL(contentsVal)
      if dataUrl
        canvas.fromDataURL(dataUrl)

      canvas.addAction
        name: "Save"
        icon: "/assets/icons/database_save.png"
        perform: (canvas) ->
          pixelEditor.trigger('save')

        undoable: false

      canvas.addAction
        name: "Save As"
        icon: "/assets/icons/database_save.png"
        perform: (canvas) ->
          title = prompt("Title")

          base64Contents = _canvas.toBase64()

          if title
            filePath = projectConfig.directories["images"]

            newFileNode
              name: title
              type: "image"
              ext: "png"
              path: filePath
              contents: "data:image/png;base64," + base64Contents

            saveFile
              contents_base64: base64Contents
              path: filePath + "/" + title + ".png"

        undoable: false

  pixelEditor = Pixie.Editor.Pixel.create(editorOptions)

  pixelEditor.bind 'save', ->
    # Update mtime to bust browser image caching
    pixelEditor.parent().attr("data-mtime", new Date().getTime())

    saveFile
      contents_base64: _canvas.toBase64()
      path: path
      success: ->
        pixelEditor.trigger "clean"

  window.currentComponent = pixelEditor

  panel.empty().append(pixelEditor)

  return pixelEditor

$.fn.modalPixelEditor = (options) ->
  input = this

  return if input.data('modalPixelEditor')

  previewImage = $ "<img />"
    src: input.val()

  input.after(previewImage).hide().data('modalPixelEditor', true)

  options = $.extend {}, options,
    initializer: (canvas) ->
      _canvas = canvas

      if dataUrl = input.val()
        canvas.fromDataURL(dataUrl)

      canvas.addAction
        name: "Store"
        icon: "/assets/icons/database_save.png"
        perform: (canvas) ->
          imageData = canvas.toDataURL()

          input.val(imageData).trigger('blur')
          previewImage.attr("src", imageData)

          $.modal.close()

          #TODO select props editor
          window.currentComponent = null

        undoable: false

  showEditor = ->
    pixelEditor = Pixie.Editor.Pixel.create(options)

    pixelEditor.modal
      containerCss:
        height: 600
        width: 800
        maxHeight: 600
        maxWidth: 800

    window.currentComponent = pixelEditor

  input.parent().click(showEditor)

  return this

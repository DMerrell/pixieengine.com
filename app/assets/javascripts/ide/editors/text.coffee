window.createTextEditor = (options, file) ->
  panel = options.panel
  {contents, id, language, path} = file.attributes

  panel.append "<textarea name='contents' style='display:none;'>#{contents}</textarea>"

  textArea = panel.find('textarea').get(0)
  savedCode = file.get 'contents'

  if language is "html"
    language = "xml"

  language ||= "dummy"

  editor = new CodeMirror.fromTextArea textArea,
    autoMatchParens: true
    content: savedCode
    height: "100%"
    lineNumbers: true
    parserfile: ["tokenize_" + language + ".js", "parse_" + language + ".js"]
    path: "/assets/codemirror/"
    stylesheet: ["/assets/codemirror/main.css"]
    tabMode: "shift"
    textWrapping: false

  $editor = $(editor)

  # Match the current theme
  $(editor.win.document).find('html').toggleClass('light', $(".bulb-sprite").hasClass('static-on'))

  # Bind all the page hotkeys to work when triggered from the editor iframe
  bindKeys(editor.win.document, hotKeys)

  # Listen for keypresses and update contents.
  processEditorChanges = ->
    currentCode = editor.getCode()

    if currentCode isnt savedCode
      $editor.trigger('dirty')
    else
      $editor.trigger('clean')

    textArea.value = currentCode

  $(editor.win.document).keyup processEditorChanges.debounce(100)

  $editor.bind "save", ->
    codeToSave = editor.getCode()

    file.set
      contents: codeToSave

    saveFile
      contents: codeToSave
      path: path
      success: ->
        # Editor's state may have changed during ajax call
        if editor.getCode() is codeToSave
          $editor.trigger "clean"
        else
          $editor.trigger "dirty"

        savedCode = codeToSave

  return $editor

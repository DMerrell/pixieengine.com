#= require animation/state
#= require animation/ui

$.fn.animationEditor = (options) ->
  animationNumber = 1
  sequenceNumber = 1
  tileIndex = 0
  lastClickedSprite = null
  lastSelectedFrame = null

  tileset = {}
  tilemap = {}
  sequences = []
  clipboard = []

  animationEditor = $(this.get(0)).addClass("editor animation_editor")

  window.exportAnimationCSV = ->
    output = ""

    for sequenceObject in sequences
      output = output + sequenceObject.name + ": " + (tilemap[frame] for frame in sequenceObject.frameArray).join(",") + "\n"

    return output

  window.exportAnimationJSON = ->
    sequenceData = (
      for sequenceObject in sequences
        {name: sequenceObject.name, frames: (tilemap[frame] for frame in sequenceObject.frameArray)}
    )

    return JSON.stringify(sequenceData)

  loadSpriteSheet = (src, rows, columns, loadedCallback) ->
    canvas = $('<canvas>').get(0)
    context = canvas.getContext('2d')

    image = new Image()

    image.onload = ->
      tileWidth = image.width / rows
      tileHeight = image.height / columns

      canvas.width = tileWidth
      canvas.height = tileHeight

      columns.times (col) ->
        rows.times (row) ->
          sourceX = row * tileWidth
          sourceY = col * tileHeight
          sourceWidth = tileWidth
          sourceHeight = tileHeight
          destWidth = tileWidth
          destHeight = tileHeight
          destX = 0
          destY = 0

          context.clearRect(0, 0, tileWidth, tileHeight)
          context.drawImage(image, sourceX, sourceY, sourceWidth, sourceHeight, destX, destY, destWidth, destHeight)

          loadedCallback?(canvas.toDataURL())

    image.src = src

  Controls = (animationEditor) ->
    intervalId = null

    scrubberMax = 30
    scrubberValue = 0
    fps = 30

    scrubber =
      max: (newMax) ->
        if newMax?
          scrubberMax = newMax
          animationEditor.trigger 'updateScrubberMax', [newMax]
          return scrubber
        else
          return scrubberMax
      val: (newValue) ->
        if newValue?
          scrubberValue = newValue
          animationEditor.trigger 'updateScrubberValue', [newValue]
          animation.currentFrameIndex(newValue)
          return scrubber
        else
          scrubberValue

    nextFrame = ->
      scrubber.val((scrubber.val() + 1) % (scrubber.max() + 1))

    changePlayIcon = (icon) ->
      el = $(".#{icon}")

      el.attr("class", "#{icon} static-#{icon}")

    self =
      fps: (newValue) ->
        if newValue?
          fps = newValue
          animationEditor.trigger 'updateFPS', [newValue]
          return self
        else
          fps

      pause: ->
        changePlayIcon('play')
        clearInterval(intervalId)
        intervalId = null

        return self

      play: ->
        if animation.frames.length > 0
          changePlayIcon('pause')
          intervalId = setInterval(nextFrame, 1000 / self.fps()) unless intervalId

        return self

      scrubber: (val) ->
        scrubber.val(val)

      scrubberMax: (val) ->
        scrubber.max(val)

      stop: ->
        scrubber.val(0)
        clearInterval(intervalId)
        intervalId = null
        changePlayIcon('play')
        animation.currentFrameIndex(-1)

    return self

  addTile = (src) ->
    id = Math.uuid(32, 16)

    tileset[id] = src
    tilemap[id] = tileIndex
    tileIndex += 1
    animationEditor.trigger 'addTile', [src]

  removeSequence = (sequenceIndex) ->
    sequences.splice(sequenceIndex, 1)
    animationEditor.trigger 'removeSequence', [sequenceIndex]

  pushSequence = (frameArray) ->
    sequences.push({name: "sequence#{sequenceNumber++}", frameArray: frameArray})
    animationEditor.trigger 'updateLastSequence'

  createSequence = ->
    if animation.frames.length
      pushSequence(animation.frames.copy())
      animation.clearFrames()

  controls = Controls(animationEditor)
  animation = Animation(animationNumber++, tileset, controls, animationEditor, sequences)
  ui = AnimationUI(animationEditor, animation, tileset, sequences)

  animationEditor.trigger 'init'

  $(document).bind 'keydown', (e) ->
    return unless e.which == 37 || e.which == 39

    index = animation.currentFrameIndex()
    framesLength = animation.frames.length

    keyMapping =
      "37": -1
      "39": 1

    controls.scrubber((index + keyMapping[e.which]).mod(framesLength))

  changeEvents =
    '.fps input': (e) ->
      newValue = $(this).val()

      controls.pause().fps(newValue).play()
    '.scrubber': (e) ->
      newValue = $(this).val()

      controls.scrubber(newValue)
      animation.currentFrameIndex(newValue)

  for key, value of changeEvents
    animationEditor.find(key).change(value)

  mousedownEvents =
    '.play': (e) ->
      if $(this).hasClass('pause')
        controls.pause()
      else
        controls.play()
    '.stop': (e) ->
      controls.stop()

  for key, value of mousedownEvents
    animationEditor.find(key).mousedown(value)

  liveMousedownEvents =
    '.bottom .x': (e) ->
      e.stopPropagation()
      parent = $(this).parent()

      if parent.hasClass('sequence')
        animation.removeFrameSequence(parent.index())

      if parent.hasClass('frame_sprite')
        animation.removeFrame(parent.index())
    '.edit_frames': (e) ->
      $this = $(this)
      text = $this.text()

      $this.text(if text == "Edit" then "Done" else "Edit")

      if text == "Edit"
        img = $ '<div />'
          class: 'x static-x'

        $('.bottom .sequence, .bottom .frame_sprite').append(img)
      else
        $('.bottom .x').remove()
    '.edit_sequences': (e) ->
      $this = $(this)
      text = $this.text()

      $this.text(if text == "Edit" then "Done" else "Edit")

      if text == "Edit"
        img = $ '<div />'
          class: 'x static-x'

        $('.right .sequence').append(img)
      else
        $('.right .x').remove()
    '.frame_sprites img, .frame_sprites .placeholder': (e) ->
      if e.shiftKey && lastSelectedFrame
        lastIndex = animationEditor.find('.frame_sprites img, .frame_sprites .placeholder').index(lastSelectedFrame)
        currentIndex = animationEditor.find('.frame_sprites img, .frame_sprites .placeholder').index($(this))

        if currentIndex > lastIndex
          sprites = animationEditor.find('.frame_sprites img, .frame_sprites .placeholder').filter ->
            imgIndex = animationEditor.find('.frame_sprites img, .frame_sprites .placeholder').index($(this))
            return lastIndex < imgIndex <= currentIndex
        else if currentIndex <= lastIndex
          sprites = animationEditor.find('.frame_sprites img, .frame_sprites .placeholder').filter ->
            imgIndex = animationEditor.find('.frame_sprites img, .frame_sprites .placeholder').index($(this))
            return currentIndex <= imgIndex < lastIndex

        sprites.addClass('selected')
        lastSelectedFrame = $(this)
      else
        index = animationEditor.find('.frame_sprites .placeholder, .frame_sprites img').index($(this))

        controls.scrubber(index)

        lastSelectedFrame = $(this)

    '.right .sequence': (e) ->
      return if $(e.target).is('.name')

      index = $(this).index()
      animation.addSequenceToFrames(index)
    '.right .x': (e) ->
      e.stopPropagation()
      removeSequence $(this).parent().index()
    '.sprites img': (e) ->
      $this = $(this)
      sprites = []

      if e.shiftKey && lastClickedSprite
        lastIndex = lastClickedSprite.index()
        currentIndex = $this.index()

        if currentIndex > lastIndex
          sprites = animationEditor.find('.sprites img').filter(->
            imgIndex = $(this).index()
            return lastIndex < imgIndex <= currentIndex
          ).get()
        else if currentIndex <= lastIndex
          sprites = animationEditor.find('.sprites img').filter(->
            imgIndex = $(this).index()
            return currentIndex <= imgIndex < lastIndex
          ).get().reverse()

        lastClickedSprite = null
      else
        sprites.push $this

        lastClickedSprite = $this

      index = if (lastSelected = animationEditor.find('.frame_sprites .selected:last')).length then animationEditor.find('.frame_sprites img').index(lastSelected) else null

      animation.addFrame($(sprite).attr('src'), index) for sprite in sprites

  for key, value of liveMousedownEvents
    animationEditor.find(key).live
      mousedown: value

  clickEvents =
    '.save_sequence': (e) ->
      createSequence()
    '.clear_frames': (e) ->
      animation.clearFrames()
      controls.stop()

  for key, value of clickEvents
    animationEditor.find(key).click(value)

  animationEditor.find('.sequences .name').liveEdit()

  animationEditor.find('.player .state_name').liveEdit().live
    change: ->
      $this = $(this)

      updatedStateName = $this.val()
      animation.name(updatedStateName)

  animationEditor.dropImageReader (file, event) ->
    if event.target.readyState == FileReader.DONE
      src = event.target.result
      name = file.fileName

      [dimensions, tileWidth, tileHeight] = name.match(/x(\d*)y(\d*)/) || []

      if tileWidth && tileHeight
        loadSpriteSheet src, parseInt(tileWidth), parseInt(tileHeight), (sprite) ->
          addTile(sprite)
      else
        addTile(src)

  $(document).bind 'keydown', 'del backspace', (e) ->
    e.preventDefault()

    selectedFrames = animationEditor.find('.frame_sprites .selected')

    for frame in selectedFrames
      index = animationEditor.find('.frame_sprites img, .frame_sprites .placeholder').index(frame)
      animation.removeFrame(index)

  $(document).bind 'keydown', '1 2 3 4 5 6 7 8 9', (e) ->
    return unless lastClickedSprite

    keyOffset = 48

    index = if (lastSelected = animationEditor.find('.frame_sprites .selected:last')).length then animationEditor.find('.frame_sprites img').index(lastSelected) else null

    (e.which - keyOffset).times ->
      animation.addFrame(lastClickedSprite.get(0).src, index)

  $(document).bind 'keydown', 'meta+c', (e) ->
    e.preventDefault()

    if (selectedSprites = animationEditor.find('.frame_sprites .selected')).length
      clipboard = selectedSprites

  $(document).bind 'keydown', 'meta+x', (e) ->
    e.preventDefault()

    if (selectedSprites = animationEditor.find('.frame_sprites .selected')).length
      clipboard = selectedSprites

    for frame in selectedSprites
      index = animationEditor.find('.frame_sprites img, .frame_sprites .placeholder').index(frame)
      animation.removeFrame(index)

  $(document).bind 'keydown', 'meta+v', (e) ->
    index = if (lastSelected = animationEditor.find('.frame_sprites .selected:last')).length then animationEditor.find('.frame_sprites img').index(lastSelected) else null

    if clipboard.length
      for frame in clipboard
        animation.addFrame($(frame).attr('src'), index)

  $(document).bind 'keydown', 'ctrl', (e) ->
    $('#clipboard_modal').children().not('.header').remove()

    for frame in clipboard
      $('#clipboard_modal').append($(frame).clone())

    $('#clipboard_modal').modal()

  $(document).bind 'keyup', 'ctrl', (e) ->
    $.modal.close()
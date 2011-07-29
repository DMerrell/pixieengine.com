$.fn.animationEditor = ->
  animationNumber = 1
  animations = []

  Controls = ->
    paused = false

    intervalId = null

    scrubberEl = $('.scrubber')

    scrubber =
      min: scrubberEl.get(0).min
      max: scrubberEl.get(0).max
      val: scrubberEl.val()

    fpsEl = $('.fps input')

    fps =
      min: fpsEl.get(0).min
      max: fpsEl.get(0).max
      val: fpsEl.val()

    updateFrame = ->
      scrubber.val = (scrubber.val + 1) % scrubber.max
      self.update()

    self =
      fps: (val) ->
        if val?
          fps.val = val
          return self
        else
          return fps.val

      play: ->
        console.log fps.val
        intervalId = setInterval(updateFrame, 1000 / fps.val) unless intervalId

      stop: ->
        scrubber.val = 0
        self.update()
        clearInterval(intervalId)
        intervalId = null

      update: ->
        scrubberEl.val(scrubber.val)

    return self

  Animation = (name) ->
    tileset = []
    sequences = []
    currentFrameIndex = 0

    name ||= "Animation #{animationNumber}"
    animationNumber += 1

    self =
      name: name

    return self

  animations.push(Animation())

  animationEditor = $(this.get(0)).addClass("editor animation_editor")

  templates = $("#animation_editor_templates")
  editorTemplate = templates.find('.editor.template')
  animationTemplate = templates.find('.animation')

  editorTemplate.tmpl().appendTo(animationEditor)

  controls = Controls()

  updateUI = ->
    for animation in animations
      animations = $('.animations')

      animations.children().remove()
      animationTemplate.tmpl(animation.name).appendTo(animations)

  updateUI()

  $('.play').mousedown -> controls.play()
  $('.stop').mousedown -> controls.stop()

  $('.fps input').change ->
    newValue = $(this).val()

    controls.stop()
    controls.fps(newValue)

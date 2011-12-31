#= require underscore
#= require backbone
#= require corelib

#= require models/frame

window.Pixie ||= {}
Pixie.Models ||= {}

class Pixie.Models.FramesCollection extends Backbone.Collection
  initialize: ->
    @selected = 0

    @bind 'add', =>
      @trigger 'enableFrameActions'

  model: Pixie.Models.Frame

  createSequence: =>
    @trigger 'createSequence'

  nextFrame: =>
    @selected = (@selected + 1).mod(@length)
    @trigger 'updateSelected', @at(@selected), @selected

  previousFrame: =>
    @selected = (@selected - 1).mod(@length)
    @trigger 'updateSelected', @at(@selected), @selected

  toFrame: (frame) =>
    @selected = frame
    @trigger 'updateSelected', @at(@selected), @selected

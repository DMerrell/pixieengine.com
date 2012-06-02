#= require templates/sprites/sprite

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Sprites ||= {}

class Pixie.Views.Sprites.Sprite extends Backbone.View
  className: 'sprite_container'

  render: =>
    $(@el).html $(JST['templates/sprites/sprite'](@model.toJSON()))
    return @


#= require underscore
#= require backbone

#= require models/sequences_collection

#= require tmpls/lebenmeister/sequences

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.Animations ||= {}

class Pixie.Views.Animations.Sequences extends Backbone.View
  el: 'nav.right'

  collection: new Pixie.Models.SequencesCollection

  initialize: ->
    @render()

  render: =>
    $(@el).append($.tmpl('lebenmeister/sequences'))

    return @


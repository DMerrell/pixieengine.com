namespace "Pixie.Editor.Tile.Views", (exports) ->
  Models = Pixie.Editor.Tile.Models

  class exports.Layer extends Backbone.View
    tagName: 'li'
    className: 'layer'

    initialize: ->
      @el = $(@el)

      @model.bind 'change', @render

      @render()

    render: =>
      @el.html "#{@model.get 'name'} <eye />"

      if @model.get 'visible'
        @el.fadeTo 'fast', 1
      else
        @el.fadeTo 'fast', 0.5

      return this

    activate: ->
      @model.trigger "activate", @model

    toggleVisible: ->
      @model.set
        visible: not @model.get 'visible'

    events:
      click: "activate"
      "click eye": "toggleVisible"

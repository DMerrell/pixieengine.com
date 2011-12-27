namespace "Pixie.Editor.Tile.Views", (Views) ->
  Models = Pixie.Editor.Tile.Models

  class Views.Entity extends Backbone.View
    tagName: 'img'
    className: 'entity'

    initialize: ->
      # Force jQuery
      @el = $(@el)

      # Add cid
      @el.attr "data-cid", @model.cid
      @el.attr "data-uuid", @model.get("uuid")

      @model.bind 'change:src', @render
      
      @options.settings.bind "change:activeEntity", (settings) =>
        if @model == settings.get "activeEntity"
          @el.takeClass("active")

      @render()

    render: =>
      @el.attr "src", @model.get "src"

      return this

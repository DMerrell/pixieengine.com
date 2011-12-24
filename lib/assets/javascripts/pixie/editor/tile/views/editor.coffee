#= require tmpls/pixie/editor/tile/editor

namespace "Pixie.Editor.Tile.Views", (exports) ->
  Models = Pixie.Editor.Tile.Models
  Views = exports

  UI = Pixie.UI

  class Views.Editor extends Backbone.View
    className: 'editor tile_editor'

    initialize: ->
      # Force jQuery Element
      @el = $(@el)

      # Set up HTML
      @el.html $.tmpl("pixie/editor/tile/editor")

      layerList = new Models.LayerList [
        new Models.Layer
          name: "Background"
        new Models.Layer
          name: "Entities"
      ]

      layerList.activeLayer(layerList.at(0))

      # Add Sub-components
      layerSelection = new Views.LayerSelection
        collection: layerList

      @$(".module.right").append layerSelection.el

      @render()

    render: =>

#= require models/tiles_collection
#= require pixie/view

namespace "Pixie.Views.Animations", (Animations) ->
  {Models} = Pixie

  class Animations.Tileset extends Pixie.View
    el: 'nav.left'

    events:
      'click img': 'addFrame'

    initialize: ->
      super

      @$('.sprites').sortable
        distance: 10

      @collection.bind 'add', (model) =>
        @addTile(model)

    addFrame: (e) =>
      cid = $(e.currentTarget).data('cid')
      model = @collection.getByCid(cid)

      @collection.trigger 'addFrame', model

    addTile: (model) =>
      src = model.get 'src'
      cid = model.cid

      img = "<img src=#{src} data-cid=#{cid}>"

      @$('.sprites').append img

    bindDropImageReader: (editorEl) =>
      editorEl.dropImageReader (file, event) =>
        if event.target.readyState == FileReader.DONE
          src = event.target.result
          name = file.fileName

          # TODO Add in support for sprite sheets
          #[dimensions, tileWidth, tileHeight] = name.match(/x(\d*)y(\d*)/) || []

          #if tileWidth && tileHeight
          #  loadSpriteSheet src, parseInt(tileWidth), parseInt(tileHeight), (sprite) ->
          #    addTile(sprite)

          @collection.add({src: src})


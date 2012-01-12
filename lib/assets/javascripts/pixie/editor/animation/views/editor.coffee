#= require underscore
#= require backbone
#= require corelib

#= require_tree .
#= require_tree ../models
#= require ../actions

#= require tmpls/editors/animation/editor

#= require pixie/editor/base
#= require pixie/view

namespace "Pixie.Editor.Animation.Views", (Views) ->
  {Animation} = Pixie.Editor
  {Models} = Pixie.Editor.Animation

  class Views.Editor extends Pixie.View
    className: 'editor backbone_lebenmeister'

    template: 'editors/animation/editor'

    initialize: ->
      super

      @settings = new Models.Settings

      @sequencesCollection = new Models.SequencesCollection
      @framesCollection = new Models.FramesCollection
      @tilesCollection = new Models.TilesCollection

      contentEl = @$('.content')

      @tilesetView = new Views.Tileset
        collection: @tilesCollection
      contentEl.append @tilesetView.el

      @framesView = new Views.Frames
        collection: @framesCollection
        settings: @settings
      contentEl.append @framesView.el

      @playerView = new Views.Player
        frames: @framesCollection
        settings: @settings
      contentEl.find('.relative').append @playerView.el

      @sequencesView = new Views.Sequences
        collection: @sequencesCollection
      contentEl.append @sequencesView.el

      for collection in [@sequencesCollection, @tilesCollection]
        collection.bind 'addToFrames', (model) =>
          @framesCollection.add model.clone()

      @framesCollection.bind 'createSequence', (collection) =>
        sequence = new Models.Sequence
          frames: collection.flattenFrames()

        @sequencesCollection.add(sequence)

      @$('.content .relative').append(@playerView.render().el)

      @tilesetView.bindDropImageReader(@el)

      @include Pixie.Editor.Base

      $.each Animation.actions, (name, action) =>
        action.name ||= name

        @addAction action

      @takeFocus()

   takeFocus: ->
     super()

    events:
      mousemove: "takeFocus"


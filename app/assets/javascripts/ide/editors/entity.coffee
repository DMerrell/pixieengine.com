#= require templates/editors/entity

$ ->
  window.entities = new Pixie.Editor.Tile.Models.EntityList()

  # Populate initial entities
  tree.getDirectory(projectConfig.directories.entities).files().each (file) ->
    {name, contents} = file.attributes

    return unless name.extension() is "entity"

    entityData = contents.parse()

    # TODO: Make sure entities get created with uuids to prevent
    # collisions from multiple people making the same file name
    # and importing/merging projects
    #
    # In the meantime just treat the file name as the uuid
    # because within a single project the file name must be
    # unique
    entityData.uuid ||= file.get("name")

    window.entities.add entityData

window.createEntityEditor = (options, file) ->
  {panel} = options
  {uuid, path, contents, name} = file.attributes

  panel.find('.editor').remove()

  defaults =
    color: '#0000FF'
    height: 32
    width: 32
    class: name.capitalize().camelize()

  try
    data = JSON.parse(contents) or defaults
  catch e
    console?.warn? e
    data = defaults

  entityEditor = $(JST["templates/editors/entity"]()).appendTo(panel)

  propertyEditor = entityEditor.find('table').propertyEditor(data)

  entityCode = data.__CODE

  textEditor = codeEditor
    panel: entityEditor.find(".content > section")
    code: entityCode
    save: (code) ->
      entityCode = code

  textEditor.bind 'dirty', ->
    entityEditor.trigger 'dirty'

  entityEditor.bind 'save', ->
    textEditor.trigger("save")

    entityData = propertyEditor.getProps()
    entityData.__CODE = entityCode
    entityData.uuid ||= name

    # Propagate changes back to IDE
    if existingEntity = entities.findByUUID(entityData.uuid)
      existingEntity.set entityData
    else
      entities.add entityData

    dataString = JSON.stringify(entityData, null, 2)

    indentedData = dataString.split("\n").map (line, i) ->
      if i > 0
        "  " + line
      else
        line
    .join("\n")

    indentedCode = entityCode.split("\n").map (line, i) ->
      "  " + line
    .join("\n")

    if entityData.class
      entitySrc = $("#file_templates .entity_class.template").tmpl(
        className: entityData.class
        parentClass: entityData.parentClass || "GameObject"
        code: indentedCode
        entityData: indentedData
      ).text()

      hotSwap(entitySrc, "coffee")

      # TODO Handle file move when renaming entity
      newFileNode
        type: "entity"
        path: "#{projectConfig.directories.source}/_#{name}.coffee"
        contents: entitySrc
        forceSave: true

    entityEditor.trigger "clean"

    file.set
      contents: dataString

    saveFile
      contents: dataString
      path: path
      success: ->

  return entityEditor

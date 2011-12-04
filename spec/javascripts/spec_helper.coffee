require '/assets/jquery/jquery.min.js'
require '/assets/jquery.tmpl.min.js'
require '/assets/sinon.js'
require '/assets/jasmine-jquery.js'
require '/assets/jasmine-sinon.js'

# fixtures
beforeEach ->
  @fixtures =
    PaginatedCollection:
      valid:
        current_user_id: 4
        page: 1
        per_page: 5
        total: 20
        models: [
          { id: 1, title: "Quest for Meaning" },
          { id: 2, title: "Pixteroids" }
        ]
    SpriteCollection:
      valid:
        current_user_id: 4
        page: 1
        per_page: 5
        total: 20
        models: [
          { id: 1, title: "Sprite 1" }
          { id: 2, title: "Sprite 2" }
          { id: 3, title: "Sprite 3" }
        ]

# server response helper
beforeEach ->
  @validResponse = (responseText) ->
    return [
      200,
      {"Content-Type": "application/json"},
      JSON.stringify(responseText)
    ]


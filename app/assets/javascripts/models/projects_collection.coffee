#= require models/paginated_collection
#= require models/project

namespace "Pixie.Models", (Models) ->
  class Models.ProjectsCollection extends Models.PaginatedCollection
    filterPages: (filter) =>
      # gross
      filter = 'none' if filter is 'all'
      filter = 'own' if filter is 'my projects'

      @page = 1
      @params.page = @page
      @params.filter = filter

      @trigger 'navigate', @params

    model: Models.Project

    pageInfo: =>
      info = super()
      _.extend(info, {owner_id: @params.id})

      return info

    parse: (data) =>
      @params.id = data.owner_id || false

      super(data)

    url: ->
      '/projects'


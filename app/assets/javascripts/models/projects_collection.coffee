#= require underscore
#= require backbone
#= require models/paginated_collection
#= require models/project

window.Pixie ||= {}
Pixie.Models ||= {}

class Pixie.Models.ProjectsCollection extends Pixie.Models.PaginatedCollection
  filterPages: (filter) =>
    # gross
    filter = 'none' if filter == 'all'
    filter = 'own' if filter == 'my projects'

    @page = 1
    @params.page = @page
    @params.filter = filter

    @fetch()

  model: Pixie.Models.Project

  pageInfo: =>
    info = super()
    _.extend(info, {owner_id: @params.id})

    return info

  parse: (data) =>
    @params.id = data.owner_id || false

    super(data)

  url: ->
    '/projects'


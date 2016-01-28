React = require 'react'
apiClient = require '../api/client'

# Responsible for rendering a pretty link to a project
ProjectCard = React.createClass
  getDefaultProps: ->
    avatar: ''
    name: ''
    slug: ''

  render: ->
    avatarSrcWithProtocol = if !!@props.avatar
      'https://' + @props.avatar

    <a href="/#{@props.slug}">
      <img src={avatarSrcWithProtocol} style={height: '1em', width: '1em'} />{' '}
      <strong>{@props.name}</strong>
    </a>


# Responsible for rendering a list of project cards
ProjectCardList = React.createClass
  getDefaultProps: ->
    projects: []

  render: ->
    <ul>
      {@props.projects.map (project) =>
        <li key={project.id}>
          <ProjectCard avatar={project.avatar_src} name={project.display_name} slug={project.slug} />
        </li>}
    </ul>


# Responsible for presenting a list of disciplines and calling `onChange` with the one the user picks
# This'll be the Filmstrip component, it just needs to conform to having `value` and `onChange` props.
DisciplineSelector = React.createClass
  getDefaultProps: ->
    value: ''
    DISCIPLINES: [
      {key: 'astronomy', label: 'Astronomy'}
      {key: 'physics', label: 'Physics'}
    ]
    onChange: ->

  handleChange: (e) ->
    @props.onChange e.target.value

  render: ->
    <span>
      <label>
        <input type='radio' name="discipline" value="" checked={@props.value is ''} onChange={@handleChange} />{' '}
        Any
      </label>
      <span>&ensp;</span>
      {@props.DISCIPLINES.map ({key, label}, i) =>
        <span key={key}>
          <label>
            <input type='radio' name="discipline" value={key} checked={key is @props.value} onChange={@handleChange} />{' '}
            {label}
          </label>
          {unless i is @props.DISCIPLINES.length - 1
            <span>&ensp;</span>}
        </span>}
    </span>


# Responsible for presenting a list of sort methods and calling `onChange` with the one the user picks
SortSelector = React.createClass
  getDefaultProps: ->
    value: 'active'
    SORT_METHODS: [
      {key: 'active', label: 'Active'}
      {key: 'inactive', label: 'Inactive'}
    ]
    onChange: ->

  handleChange: (e) ->
    @props.onChange e.target.value

  render: ->
    <select value={@props.value} onChange={@handleChange}>
      {@props.SORT_METHODS.map ({key, label}) =>
        <option key={key} value={key}>{label}</option>}
    </select>


# Responsible for presenting a list of pages (passed in as props) and calling onChange with the one the user picks
# I think we have a generic one of these already.
PageSelector = React.createClass
  getDefaultProps: ->
    current: 1
    total: 0

  handleChange: (e) ->
    @props.onChange e.target.value

  render: ->
    <select value={@props.current} disabled={@props.total is 0} onChange={@handleChange}>
      {[1..@props.total].map (page) =>
        <option key={page}>{page}</option>}
    </select>


# The ProjectFilteringInterface is responsible for:
# - Using its props to query for whatever data is needed to render the projects list
# - Rendering the various filtering controls (including pagination)
# - Passing changes to the query from those controls up to the ProjectsPage
ProjectFilteringInterface = React.createClass
  getDefaultProps: ->
    discipline: ''
    page: 1
    sort: '-activity'

    # To separate the API from the UI (and present the user with more friendly query terms):
    SORT_QUERY_VALUES:
      'active': '-last_modified'
      'inactive': 'last_modified'

  getInitialState: ->
    projects: []
    pages: 0
    loading: false
    error: null

  componentDidMount: ->
    {discipline, page, sort} = @props
    @loadProjects {discipline, page, sort}

  componentWillReceiveProps: (nextProps) ->
    {discipline, page, sort} = nextProps
    if discipline isnt @props.discipline or page isnt @props.page or sort isnt @props.sort
      @loadProjects {discipline, page, sort}

  loadProjects: ({discipline, page, sort}) ->
    @setState
      loading: true
      error: null

    query =
      tags: discipline || undefined
      page: page
      sort: @props.SORT_QUERY_VALUES[sort] ? @constructor.defaultProps.sort
      launch_approved: true
      cards: true
      include: ['avatar']

    unless !!query.tags
      delete query.tags

    apiClient.type('projects').get(query)
      .then (projects) =>
        pages = projects[0]?.getMeta()?.page_count
        @setState {projects, pages}
      .catch (error) =>
        @setState {error}
      .then =>
        @setState loading: false

  handleDisciplineChange: (discipline) ->
    this.props.onChangeQuery {discipline}

  handleSortChange: (sort) ->
    this.props.onChangeQuery {sort}

  handlePageChange: (page) ->
    this.props.onChangeQuery {page}

  render: ->
    <div>
      <header>
        <p>
          Discipline:{' '}
          <DisciplineSelector value={@props.discipline} onChange={@handleDisciplineChange} />
        </p>
        <p>
          <label>
            Sort order:{' '}
            <SortSelector value={@props.sort} onChange={@handleSortChange} />
          </label>
        </p>
      </header>

      {if @state.error?
        <p className="form-help error">{@state.error.toString()}</p>
      else
        <div>
          {if @state.loading
            <p className="form-help">Loading projects...</p>}
          <ProjectCardList projects={@state.projects} />
          <footer>
            <nav>
              Page:{' '}
              <PageSelector current={@props.page} total={@state.pages} onChange={@handlePageChange} />{' '}
              of {@state.pages}
            </nav>
          </footer>
        </div>}
    </div>


# The ProjectsPage is responsible for:
# - Turning URL query (which it gets from the router) into useful props
# - Give the FilteringInterface a callback to update the URL query
ProjectsPage = React.createClass
  getDefaultProps: ->
    location:
      query:
        discipline: ProjectFilteringInterface.defaultProps.discipline
        page: ProjectFilteringInterface.defaultProps.page
        sort: ProjectFilteringInterface.defaultProps.sort

  updateQuery: (newParams) ->
    query = Object.assign {}, @props.location.query, newParams
    for key, value of query
      if value is ''
        delete query[key]
    newLocation = Object.assign {}, @props.location, {query}
    @props.history.replace newLocation

  render: ->
    {discipline, page, sort} = @props.location.query
    listingProps = {discipline, page, sort}
    <ProjectFilteringInterface {...listingProps} onChangeQuery={@updateQuery} />

module.exports = ProjectsPage

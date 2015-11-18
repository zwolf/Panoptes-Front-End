React = require 'react'
ChartistGraph = require 'react-chartist'
moment = require 'moment'
qs = require 'qs'

CHARTIST_CSS = '//cdn.jsdelivr.net/chartist.js/latest/chartist.min.css'

MS_PER_HOUR = 3600000
NOW = Date.now()

mockData =
  classifications:
    hourly: ({
      label: NOW - (MS_PER_HOUR * i)
      value: Math.random() * 250
    } for i in [0...24])
    daily: ({
      label: NOW - (MS_PER_HOUR * i)
      value: Math.random() * 250
    } for i in [0...14])
    weekly: ({
      label: NOW - (MS_PER_HOUR * i)
      value: Math.random() * 250
    } for i in [0...8])
  volunteers:
    hourly: ({
      label: NOW - (MS_PER_HOUR * i)
      value: Math.random() * 250
    } for i in [0...24])
    daily: ({
      label: NOW - (MS_PER_HOUR * i)
      value: Math.random() * 250
    } for i in [0...14])
    weekly: ({
      label: NOW - (MS_PER_HOUR * i)
      value: Math.random() * 250
    } for i in [0...8])

Graph = React.createClass
  getDefaultProps: ->
    data: []
    options: {}

  componentDidMount: ->
    # Hack day!
    unless document.querySelector "[href='#{CHARTIST_CSS}']"
      link = document.createElement 'link'
      link.rel = 'stylesheet'
      link.href = CHARTIST_CSS
      document.head.appendChild link

  formatLabel:
    hourly: (date) -> moment(date).format 'h'

  render: ->
    data =
      labels: []
      series: [[]]

    @props.data.forEach ({label, value}) =>
      data.labels.push @formatLabel[@props.by]?(label) ? label
      data.series[0].push value

    <div style={background: 'white'}>
      <ChartistGraph type="Bar" data={data} options={@props.options} />
    </div>

ProjectStatsPage = React.createClass
  getDefaultProps: ->
    totalClassifications: 1324354
    requiredClassifications: 3546576
    totalVolunteers: 243
    currentVolunteers: 46
    classificationsBy: 'hourly'
    volunteersBy: 'hourly'

  render: ->
    <div className="project-stats-page">
      <div className="project-stats-dashboard">
        <div className="major">
          {@props.totalClassifications}<br />
          Classifications
        </div>
        <div>
          {@props.totalVolunteers}<br />
          Volunteers
        </div>

        <div className="major">
          <meter value={@props.totalClassifications} max={@props.requiredClassifications} /><br />
          {Math.floor 100 * (@props.totalClassifications / @props.requiredClassifications)}% complete
        </div>
        <div>
          {@props.currentVolunteers}<br />
          Online now
        </div>
      </div>

      <div>
        Classifications per{' '}
        <select value={@props.classificationsBy} onChange={@handleGraphChange.bind this, 'classifications'}>
          <option value="hourly">hour</option>
          <option value="daily">day</option>
          <option value="weekly">week</option>
        </select><br />
        <Graph data={mockData.classifications[@props.classificationsBy]} />
      </div>

      <div>
        Volunteers per{' '}
        <select value={@props.volunteersBy} onChange={@handleGraphChange.bind this, 'volunteers'}>
          <option value="hourly">hour</option>
          <option value="daily">day</option>
          <option value="weekly">week</option>
        </select><br />
        <Graph data={mockData.volunteers[@props.volunteersBy]} />
      </div>
    </div>

  handleGraphChange: (which, e) ->
    query = qs.parse location.search.slice 1
    query[which] = e.target.value
    location.search = qs.stringify query

ProjectStatsPageController = React.createClass
  render: ->
    queryProps =
      classificationsBy: @props.query.classifications
      volunteersBy: @props.query.volunteers

    <ProjectStatsPage {...queryProps} />

module.exports = ProjectStatsPageController

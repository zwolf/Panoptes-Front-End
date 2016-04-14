React = require 'react'

NavigationEditor = React.createClass
  render: ->
    <div>TODO</div>

PageEditor = React.createClass
  render: ->
    <div>TODO</div>

PagesEditor = React.createClass
  getDefaultProps: ->
    project: null

  render: ->
    <div>
      <div className="columns-container">
        <div>
          <div className="form-label">Navigation</div>
          <NavigationEditor />
        </div>
        <div>
          <div className="form-label">Content</div>
          <PageEditor />
        </div>
      </div>
    </div>

module.exports = PagesEditor

config = require './config'
panoptesClient = require 'panoptes-client'

{api} = new PanoptesClient
  appID: config.clientAppID,
  host: config.host
  root: '/api'
  headers:
    'Content-Type': 'application/json'
    'Accept': 'application/vnd.api+json; version=1'

module.exports = api
window?.panoptesApi = api

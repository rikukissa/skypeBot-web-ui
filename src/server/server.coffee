api     = require('./api')
express = require('express')

module.exports.createServer = (config) ->
  app     = express()
  httpd   = require('http').createServer(app)

  app.use express.static('public')
  app.use express.bodyParser()
  api.init(app, config)

  return httpd
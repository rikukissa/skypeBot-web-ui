fs      = require('fs')
api     = require('./api')
express = require('express')

module.exports.createServer = () ->
  app     = express()
  httpd   = require('http').createServer(app)

  app.use express.static('public')
  app.use express.bodyParser()

  config = JSON.parse fs.readFileSync('config.json')

  api.init(app, config)

  return httpd
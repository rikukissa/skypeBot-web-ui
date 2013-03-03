fs = require('fs')
config = JSON.parse fs.readFileSync('config.json')

httpd = require('./src/server/server').createServer(config)
httpd.listen(config.httpPort)

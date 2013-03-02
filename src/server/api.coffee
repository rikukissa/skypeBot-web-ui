Mongolian = require('mongolian')
moment    = require('moment')

# Options
urlRegex = /(https?|ftp):\/\/(([\w\-]+\.)+[a-zA-Z]{2,6}|\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})(:\d+)?(\/([\w\-~.#\/?=&;:+%!*\[\]@$\()+,|\^]+)?)?/

formatArray = (array) ->
  delete entry._id for entry in array
  return array

module.exports.init = (app, config) ->
  # Database config
  db = new Mongolian config.mongoAddr
  messages = db.collection 'messages'

  # Message API
  app.get '/api/messages/tag/:tag', (req, res) ->
    tagRegex =  new RegExp('(^|\\s)#(\\w*' + req.params.tag + '\\w*)', 'i')
    messages.find(
      body:
        $regex: tagRegex
    ).sort( timestamp: -1 ).limit(100).toArray (err, arr) ->
      res.send formatArray(arr)

  app.get '/api/messages/links', (req, res) ->
    messages.find(
      body:
        $regex: urlRegex
    ).sort( timestamp: -1 ).limit(100).toArray (err, arr) ->
      res.send formatArray(arr)
  
  app.get '/api/messages', (req, res) ->
    messages.find().sort( timestamp: -1 ).limit(100).toArray (err, arr) ->
      res.send formatArray(arr)

  # Stats API
  app.get '/api/stats', (req, res) ->
    stats =
      firstMessageAt: null
      lastMessageAt: null
      messageCount: 0
      messageCountPerHour: []
      fetched: Date.now()
      users: []


    # Search for users
    messages.find().toArray (err, arr) ->
      stats.users._users = []
      stats.messageCount = arr.length
      stats.messageCountPerHour[i] = 0 for i in [0..23]

      for m, i in arr
        stats.firstMessageAt = m.timestamp if i == 0
        stats.lastMessageAt = m.timestamp if i == arr.length - 1
        if stats.users._users.indexOf(m.username) == -1 # New user entry
          stats.users._users.push m.username
          stats.users.push 
            username: m.username
            displayNames: [m.displayName]
            messageCount: 1
        else # Existing user
          index = stats.users._users.indexOf(m.username)
          stats.users[index].messageCount++
          if stats.users[index].displayNames.indexOf(m.displayName) == -1
            stats.users[index].displayNames.push m.displayName 

        # Messages according time
        hour = moment.unix(m.timestamp).format('H')
        stats.messageCountPerHour[hour]++

      res.send(stats)
  app.get '*', (req, res) -> 
    res.sendfile('public/index.html')
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
  app.get '/api/stats/words', (req, res) ->
    stats =
      words: []
    messages.find().toArray (err, arr) ->
      wordList = {}

      for m, i in arr
        delete m._id

        words = m.body.split(' ')    
        for word in words
          wordList[word] = 0 if !wordList[word]?
          wordList[word]++

      for word of wordList
        stats.words.push [word, wordList[word]]

      stats.words.sort (a, b) -> return a[1] - b[1]
      stats.words.splice(0, 100)
      stats.words.reverse()
      res.send(stats)

  app.get '/api/stats', (req, res) ->
    stats =
      firstMessageAt: null
      lastMessageAt: null
      messageCount: 0
      messageCountPerHour: []
      fetchedAt: Date.now()
      users: []

    messages.find().toArray (err, arr) ->
      stats.users._users = []
      stats.messageCount = arr.length # Messages combined
      stats.messageCountPerHour[i] = 0 for i in [0..23]

      for m, i in arr
        delete m._id
        stats.firstMessageAt = m.timestamp if i == 0 # First message at
        stats.lastMessageAt = m.timestamp if i == arr.length - 1 # Last message at

        # Messages according time
        hour = moment.unix(m.timestamp).format('H')
        stats.messageCountPerHour[hour]++
        
        if stats.users._users.indexOf(m.username) == -1 # User
          stats.users._users.push m.username
          user =
            username: m.username # User username
            displayNames: [m.displayName]
            messageCount: 1
            recentMessages: []
            messageCountPerHour: []
          user.messageCountPerHour[i] = 0 for i in [0..23]
          stats.users.push user
        else
          index = stats.users._users.indexOf(m.username)
          stats.users[index].messageCount++ # User message count
          
          if stats.users[index].displayNames.indexOf(m.displayName) == -1 # User display names
            stats.users[index].displayNames.push m.displayName 

          stats.users[index].firstMessage = m if !stats.users[index].firstMessage?
          stats.users[index].recentMessages.splice 0, 1 if stats.users[index].recentMessages.length > 4
          stats.users[index].recentMessages.push m
          stats.users[index].messageCountPerHour[hour]++

      res.send(stats)
  app.get '*', (req, res) -> 
    res.sendfile('public/index.html')
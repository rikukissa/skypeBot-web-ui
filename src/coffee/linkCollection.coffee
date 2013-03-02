define (require) ->
  Backbone      = require('backbone')
  LinkCollection = Backbone.Collection.extend(url: '/api/messages/links')
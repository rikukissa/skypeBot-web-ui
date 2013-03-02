define (require) ->
  Backbone = require('backbone')
  TagCollection = Backbone.Collection.extend 
    initialize: (@options) ->
    url: -> '/api/messages/tag/' + @options.keyword
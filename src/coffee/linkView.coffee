define (require) ->

  $              = require('jquery')
  utils          = require('utils')
  Backbone       = require('backbone')
  Transparency   = require('transparency')
  
  LinkCollection = require('linkCollection')
 
  Backbone.View.extend  
    el: $('#messages')
    
    initialize: ->
      Transparency.register $
      
      linkCollection = new LinkCollection
      linkCollection.on 'reset', @render
      linkCollection.fetch()

    render: (linkCollection) ->
      content = linkCollection.toJSON()
      directives =
        timestamp:
          html: -> utils.formatTimestamp(@timestamp)
        body:
          html: ->  utils.formatBody @body
      $('#messages tbody').render content, directives
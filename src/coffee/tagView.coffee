define (require) ->

  $             = require('jquery')
  utils         = require('utils')
  Backbone      = require('backbone')
  Transparency  = require('transparency')
  tagCollection = require('tagCollection')
    

  Backbone.View.extend  
    el: $('#messages')
    initialize: (options) ->
      Transparency.register $
      
      tagCollection = new tagCollection
        keyword: options.keyword

      tagCollection.on 'reset', @render
      tagCollection.fetch()

    render: (tagCollection) ->
      content = tagCollection.toJSON()
      directives =
        timestamp:
          html: -> utils.formatTimestamp(@timestamp)
        body:
          html: ->  utils.formatBody @body

      $('#messages tbody').render content, directives
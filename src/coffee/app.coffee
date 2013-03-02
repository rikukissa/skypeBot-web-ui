
define (require) ->
  moment        = require('moment')
  Backbone      = require('backbone')
  Transparency  = require('transparency')
  Highcharts    = require('highcharts')

  # Backbone views
  LinkView      = require('linkView')
  TagView       = require('tagView')
  StatsView     = require('statsView')

  main: () ->
    class Router extends Backbone.Router
      routes:
        '': 'defaultView'
        'tag/:tag': 'tagView'
        'stats': 'statsView'

      tagView: (keyword) -> new TagView keyword: keyword
      defaultView: -> new LinkView      
      statsView: -> new StatsView

    appRouter = new Router()
    Backbone.history.start pushState: true



define (require) ->
  ko            = require('knockout')
  moment        = require('moment')
  Backbone      = require('backbone')
  Transparency  = require('transparency')

  # Backbone views
  LinkView      = require('linkView')
  TagView       = require('tagView')
  StatsView     = require('statsView')


  class ViewModel
    constructor: ->
      @currentView = ko.observable('listView')
  
  vmo = new ViewModel
  
  ko.applyBindings vmo

  main: () ->
    class Router extends Backbone.Router
      routes:
        '': 'defaultView'
        'tag/:tag': 'tagView'
        'stats': 'statsView'

      tagView: (keyword) -> 
        vmo.currentView('listView')
        new TagView keyword: keyword
      defaultView: -> 
        vmo.currentView('listView')
        new LinkView      
      statsView: -> 
        vmo.currentView('statsView')
        new StatsView


    appRouter = new Router()
    Backbone.history.start pushState: true


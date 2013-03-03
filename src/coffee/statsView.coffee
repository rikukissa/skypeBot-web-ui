define (require) ->

  $              = require('jquery')
  utils          = require('utils')
  Backbone       = require('backbone')
  Transparency   = require('transparency')
  Highcharts     = require('highcharts')

  Backbone.View.extend  
    initialize: ->
      $.getJSON '/api/stats', @render
    
    render: (stats) ->

      $('#stats .title').html("Viestit (#{stats.messageCount}kpl) ajalta #{utils.formatTimestamp(stats.firstMessageAt)} - #{utils.formatTimestamp(stats.lastMessageAt)}")

      # User messages
      series = []
      series.push [user.username, user.messageCount] for user in stats.users

      Highcharts.getOptions().colors = Highcharts.map(Highcharts.getOptions().colors, (color) ->
        radialGradient:
          cx: 0.5
          cy: 0.3
          r: 0.7
        stops: [[0, color], [1, Highcharts.Color(color).brighten(-0.3).get("rgb")]]
      )

      new Highcharts.Chart(
        chart:
          renderTo: "userMessageCount"
          plotBackgroundColor: null
          plotBorderWidth: null
          plotShadow: false

        title:
          text: "Viestijakauma käyttäjien mukaan"
        tooltip:
          pointFormat: "{series.name}: <b>{point.percentage}%</b>"
          percentageDecimals: 1

        plotOptions:
          pie:
            allowPointSelect: true
            cursor: "pointer"
            dataLabels:
              enabled: true
              color: "#000000"
              connectorColor: "#000000"
              formatter: -> "<b>#{@point.name}</b>: #{@y} kpl"

        series: [
          type: "pie"
          name: "Viestien osuus"
          data: series
        ]
      )

      # Messages by time
      categories = []
      categories.push i + "" for i in [0..23]
      
      new Highcharts.Chart(
        chart:
          renderTo: "messageCountPerHour"
          type: "spline"

        title:
          text: "Viestimäärät kellonajan mukaan"

        xAxis:
          categories: categories

        yAxis:
          title:
            text: "Viestien määrä"

          min: 0
          minorGridLineWidth: 0
          gridLineWidth: 0
          alternateGridColor: null

        tooltip:
          formatter: -> @y + "kpl"
          
        series: [
          name: "Kaikki viestit"
          data: stats.messageCountPerHour
        ]
        navigation:
          menuItemStyle:
            fontSize: "10px"
      )
      # User by time
      categories = []
      categories.push i + "" for i in [0..23]

      series = []
      for u in stats.users
        series.push
          name: u.username
          data: u.messageCountPerHour
      
      new Highcharts.Chart(
        chart:
          renderTo: "userMessageCountPerHour"
          type: "spline"

        title:
          text: "Viestimäärät kellonajan mukaan"

        xAxis:
          categories: categories

        yAxis:
          title:
            text: "Viestien määrä"

          min: 0
          minorGridLineWidth: 0
          gridLineWidth: 0
          alternateGridColor: null

        tooltip:
          formatter: -> @y + "kpl"
          
        series: series
        navigation:
          menuItemStyle:
            fontSize: "10px"
      )
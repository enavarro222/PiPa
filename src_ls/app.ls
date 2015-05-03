define do
  [ \jquery \react 'prelude-ls' \backbone \moment, \dboard, \widget]
  ($, React, Prelude, Backbone, moment, dboard, widget) ->
    # Advanced functional style programming using prelude-ls
    {map, filter, slice, lines, any, fold, Str} = require 'prelude-ls'
    # DOM building function from React
    {i, div, tr, td, span, kbd, button, ul, li, a, h1, h2, h3, input, form, table, th, tr, td, thead, tbody, label, nav, p, ruby, rt} = React.DOM

    DEBUG = true

    #configure moment locale
    moment.locale "fr"

    # callback that build dashboards
    defineDashboards = (sources, dashboards) ->
      console.log "Create dashboards !"
      MainDashboard = React.create-class do
        mixins: [dboard.AbstractGridDashboard]
        render: ->
          div {className: 'gridster'},
            ul {ref: 'maingrid'},
              li {'data-row': 1, 'data-col': 1, 'data-sizex': 3, 'data-sizey': 1},
                div {className: 'ui segment grid swidget'},
                  div {className: 'ui ten wide column'},
                    widget.TimeDate {}
                  div {className: 'ui six wide column'},
                    widget.WeekNum {}
              li {'data-row': 1, 'data-col': 4, 'data-sizex': 1, 'data-sizey': 1},
                widget.TextGauge do
                  model: sources.get \count
                  label: "count"
              li {'data-row': 1, 'data-col': 8, 'data-sizex': 1, 'data-sizey': 1},
                widget.TextGauge do
                  model: sources.get \cpu
                  icon: "dashboard"
              li {'data-row': 2, 'data-col': 4, 'data-sizex': 1, 'data-sizey': 1},
                widget.TextGauge do
                  model: sources.get \tlse_temp
                  format_value: (tval) -> tval.toFixed(1)
                  icon: "world"

              li {'data-row': 2, 'data-col': 1, 'data-sizex': 2, 'data-sizey': 2},
                widget.CircleGauge do
                  model: sources.get \cpu
                  min: 0
                  max: 100

      SecondDashboard =  React.create-class do
        mixins: [dboard.AbstractGridDashboard]
        render: ->
          div {className: 'gridster'},
            ul {ref: 'maingrid'},
              li {'data-row': 1, 'data-col': 4, 'data-sizex': 3, 'data-sizey': 1},
                div {className: 'ui segment grid swidget'},
                  div {className: 'ui ten wide column'},
                    widget.TimeDate {}
                  div {className: 'ui six wide column'},
                    widget.WeekNum {}

              li {'data-row': 1, 'data-col': 1, 'data-sizex': 3, 'data-sizey': 3},
                widget.CircleGauge do
                  model: sources.get \cpu
                  icon: "dashboard"
                  min: 0
                  max: 100

      # register the dashboards
      dashboards["main"] = MainDashboard {}
      dashboards["second"] = SecondDashboard {}
      
      # return default dashboard
      'main'

    # returned value: just the main component
    app = React.createElement dboard.DBoardApp, {dboardBuilder: defineDashboards, debug: DEBUG}
    if DEBUG
      window.app = app
    app

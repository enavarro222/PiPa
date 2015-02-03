define do
  [ \jquery \react 'prelude-ls' \backbone \gridster \io \moment, \widget]
  ($, React, Prelude, Backbone, Gridster, io, moment, widget) ->
    # Advanced functional style programming using prelude-ls
    {map, filter, slice, lines, any, fold, Str} = require 'prelude-ls'
    # DOM building function from React
    {i, div, tr, td, span, kbd, button, ul, li, a, h1, h2, h3, input, form, table, th, tr, td, thead, tbody, label, nav, p, ruby, rt} = React.DOM

    DEBUG = true

    #configure moment locale
    moment.locale "fr"

    SourceModel = Backbone.Model.extend do
      name: "source"

      defaults:
        value: 42
        unit: null
        last_update: null
        timeout: 60*3      # bydefault becames outdated after 3 mins
        outdated: false     # whether the data is outdated
        error: null         # error msg when outdated

      url: ->
        'http://' + document.domain + ':' + location.port + "/source/" + @name

      initialize: (attr, options) ->
        @name = options.name || @name
        @checkOutDatedTimeout = null
        @socket = io.connect @url!
        # update model when data are send on msg "change"
        @socket.on \update @newDataPushed.bind @
        @fetch do
          success: @checkOutDated.bind @
        @

      newDataPushed: (data) ->
        @set data
        @checkOutDated!

      checkOutDated: ->
        clearTimeout @checkOutDatedTimeout
        lastUpdate = moment @.get 'last_update'
        if lastUpdate.isValid!
          timeout = @.get \timeout
          if moment!.diff(lastUpdate, \second) > timeout
            @.set \outdated, true
            @.set \error, (lastUpdate.fromNow true)
          else
            @.set \outdated, false
            @.set \error, null
          # check every 15 seconds max:
          @checkOutDatedTimeout = setTimeout (@checkOutDated.bind @), (Math.min timeout, 15)*1000
        @


    # definition des sources de données
    sources =
      count: new SourceModel {}, {name: "count"}
      cpu: new SourceModel {}, {name: "cpu"}
      extTemp: new SourceModel {}, {name: "ext_temp"}
      grangeTemp: new SourceModel {}, {name: "grange_temp"}

    if DEBUG
      window.sources = sources

    AppMain = React.create-class do
      render: ->
        div {className: 'gridster'},
          ul {ref: 'maingrid'},
            li {'data-row': 1, 'data-col': 1, 'data-sizex': 3, 'data-sizey': 1},
              div {className: 'ui segment grid'},
                div {className: 'ui ten wide column'},
                  widget.TimeDate {}
                div {className: 'ui six wide column'},
                  widget.WeekNum {}
            li {'data-row': 1, 'data-col': 1, 'data-sizex': 1, 'data-sizey': 1},
              div {className: 'ui segment'},
                "TEST"
            li {'data-row': 2, 'data-col': 3, 'data-sizex': 1, 'data-sizey': 1},
              widget.TextGauge do
                model: sources.count
                label: "count"
            li {'data-row': 2, 'data-col': 3, 'data-sizex': 1, 'data-sizey': 1},
              widget.TextGauge do
                model: sources.extTemp
                label: 
                  span {className: 'ui small header'},
                    "Temp. ext."
            li {'data-row': 2, 'data-col': 3, 'data-sizex': 1, 'data-sizey': 1},
              widget.TextGauge do
                model: sources.grangeTemp
                label: 
                  span {className: 'ui small header'},
                    "Temp. grange"
            li {'data-row': 1, 'data-col': 4, 'data-sizex': 1, 'data-sizey': 1},
              widget.TextGauge do
                model: sources.cpu
                icon: "dashboard"

      componentDidMount: ->
        @grid = ($ @refs.maingrid.getDOMNode!).gridster do
          'widget_margins': [10, 10]
          'widget_base_dimensions': [140, 140]
          'max_cols': 15
          'min_cols': 1
        .data 'gridster'
        @grid.disable()

    # returned value: just the main component
    AppMain

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
        timeout: 60*3       # bydefault becames outdated after 3 mins
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
        console.log "new data", data
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
            if @get \outdated
              @.set \error, false
            @.set \outdated, false
          # check every 15 seconds max:
            @checkOutDatedTimeout = setTimeout (@checkOutDated.bind @), (Math.min timeout, 15)*1000
        @


    # definition des sources de données
    #TODO decouverte en auto !
    sources =
      count: new SourceModel {}, {name: "count"}
      cpu: new SourceModel {}, {name: "cpu"}
      extTemp: new SourceModel {}, {name: "ext_temp"}
      extHum: new SourceModel {}, {name: "ext_hum"}
      grangeTemp: new SourceModel {}, {name: "grange_temp"}

    if DEBUG
      window.sources = sources

    AppMain = React.create-class do
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
                model: sources.count
                label: "count"
            li {'data-row': 1, 'data-col': 5, 'data-sizex': 1, 'data-sizey': 1},
              widget.TextGauge do
                model: sources.extTemp
                label: 
                  span {className: 'ui small header'},
                    "Temp. ext."
            li {'data-row': 1, 'data-col': 6, 'data-sizex': 1, 'data-sizey': 1},
              widget.TextGauge do
                model: sources.extHum
                label: 
                  span {className: 'ui small header'},
                    "Hum. ext."
            li {'data-row': 1, 'data-col': 7, 'data-sizex': 1, 'data-sizey': 1},
              widget.TextGauge do
                model: sources.grangeTemp
                label: 
                  span {className: 'ui small header'},
                    "Temp. grange"
            li {'data-row': 1, 'data-col': 8, 'data-sizex': 1, 'data-sizey': 1},
              widget.TextGauge do
                model: sources.cpu
                icon: "dashboard"

            li {'data-row': 2, 'data-col': 1, 'data-sizex': 2, 'data-sizey': 2},
              widget.CircleGauge do
                model: sources.cpu
                icon: "dashboard"
                min: 0
                max: 100

            li {'data-row': 3, 'data-col': 1, 'data-sizex': 1, 'data-sizey': 1},
              div {className: 'ui segment swidget'},
                "TEST"
            li {'data-row': 4, 'data-col': 1, 'data-sizex': 1, 'data-sizey': 1},
              div {className: 'ui segment swidget'},
                "TEST"
            li {'data-row': 4, 'data-col': 3, 'data-sizex': 1, 'data-sizey': 1},
              div {className: 'ui segment swidget'},
                "TEST A"
            li {'data-row': 4, 'data-col': 7, 'data-sizex': 1, 'data-sizey': 1},
              div {className: 'ui segment swidget'},
                "TEST FIN"


      componentDidMount: ->
        w = 145
        h = 145
        mw = 10
        mh = 10
        @grid = ($ @refs.maingrid.getDOMNode!).gridster do
          'widget_margins': [mw, mh]
          'widget_base_dimensions': [w, h]
          'max_cols': 8
          'min_cols': 8
        .data 'gridster'
        @grid.disable()
        $ @refs.maingrid.getDOMNode!
          .find("li").each (i, li) ->
            sizex = ($ li).attr "data-sizex"
            sizey = ($ li).attr "data-sizey"
            widgetW = w*sizex + 2*mw*(sizex - 1)
            widgetH = h*sizey + 2*mh*(sizey - 1)
            ($ li).first().children().first()
              .width widgetW
              .height widgetH

    # returned value: just the main component
    AppMain

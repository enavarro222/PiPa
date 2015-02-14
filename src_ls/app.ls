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
      idAttribute: "name"

      defaults:
        name: null
        value: 42
        unit: null
        last_update: null
        timeout: 60*3       # bydefault becames outdated after 3 mins
        outdated: false     # whether the data is outdated
        error: null         # error msg when outdated

      url: ->
        'http://' + document.domain + ':' + location.port + "/source/" + (@get \name)

      initialize: (attr, options) ->
        #TODO manage 404, unexisting source
        console.log "Init source (" + (@get \name) + ")"
        #console.log "url: " + @.url!
        @checkOutDatedTimeout = null
        @socket = io.connect @url!
        # update model when data are send on msg "change"
        @socket.on \update @newDataPushed.bind @
        @fetch do
          success: @checkOutDated.bind @
        @

      newDataPushed: (data) ->
        #console.log "new data", data
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


    SourcesCollection = Backbone.Collection.extend do
        url: ->
          '/source'
        model: SourceModel

        parse: (data) ->
          data.sources


    AbstractGridDashboard =
      widget_w: 145
      widget_h: 145
      margin_w: 10
      margin_h: 10
      componentDidMount: ->
        w = @widget_w
        h = @widget_h
        mw = @margin_w
        mh = @margin_h
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


    defineDashboards = (sources, dashboards) ->
      console.log "Create dashboards !"
      MainDashboard = React.create-class do
        mixins: [AbstractGridDashboard]
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
              li {'data-row': 1, 'data-col': 5, 'data-sizex': 1, 'data-sizey': 1},
                widget.TextGauge do
                  model: sources.get \extTemp
                  label: 
                    span {className: 'ui small header'},
                      "Temp. ext."
              li {'data-row': 1, 'data-col': 6, 'data-sizex': 1, 'data-sizey': 1},
                widget.TextGauge do
                  model: sources.get \extHum
                  label: 
                    span {className: 'ui small header'},
                      "Hum. ext."
              li {'data-row': 1, 'data-col': 7, 'data-sizex': 1, 'data-sizey': 1},
                widget.TextGauge do
                  model: sources.get \grangeTemp
                  label: 
                    span {className: 'ui small header'},
                      "Temp. grange"
              li {'data-row': 1, 'data-col': 8, 'data-sizex': 1, 'data-sizey': 1},
                widget.TextGauge do
                  model: sources.get \cpu
                  icon: "dashboard"

              li {'data-row': 2, 'data-col': 1, 'data-sizex': 2, 'data-sizey': 2},
                widget.CircleGauge do
                  model: sources.get \cpu
                  icon: "dashboard"
                  min: 0
                  max: 100

              li {'data-row': 2, 'data-col': 1, 'data-sizex': 2, 'data-sizey': 2},
                widget.CircleGauge do
                  model: sources.get \consoPc
                  icon: "dashboard"
                  min: 0
                  max: 300

      SecondDashboard =  React.create-class do
        mixins: [AbstractGridDashboard]
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
                  model: sources.get \consoPc
                  icon: "dashboard"
                  min: 0
                  max: 300

      # register the dashboards
      dashboards["main"] = MainDashboard {}
      dashboards["second"] = SecondDashboard {}
      'main'

    # default waiting dashboard
    WaitDashboard = React.create-class do
      render: ->
        div {className: "ui active dimmer"},
          div {className: "ui loader"}

    AppMain = React.create-class do
      url: ->
        'http://' + document.domain + ':' + location.port + "/dash"

      # list all available dashboards
      dashboards:
        wait: WaitDashboard {}
  
      # alls data sources
      sources: new SourcesCollection []

      getInitialState: ->
        dash: \wait

      componentWillMount: ->
        if DEBUG
          window.sources = @sources
          window.dashboards = @dashboards
        # fetch sources
        console.log("create")
        @sources.fetch do
          success: @createAppDashboards.bind @
        # connect on dashboard change from server
        @socket = io.connect @url!
        # update model when data are send on msg "change"
        @socket.on \update @dashUpdated.bind @

      createAppDashboards: ->
        #call external function
        dash = defineDashboards(@sources, @dashboards)
        @setState do
            dash: dash

      componentWillUnmount: ->
        @socket.off \update @dashUpdated.bind @

      dashUpdated: (data) !->
        new_dash = data.dash
        if new_dash of @dashboards
          @setState do
            dash: new_dash
        else
          console.log("ERROR: server ask an unexisting dash ('#new_dash')")

      render: ->
        # render the selected dashboard
        @dashboards[@state.dash]

    if DEBUG
      window.app = AppMain

    # returned value: just the main component
    AppMain

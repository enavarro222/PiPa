define do
  [ \jquery \react 'prelude-ls' \backbone \gridster \io]
  ($, React, Prelude, Backbone, Gridster, io) ->
    # Advanced functional style programming using prelude-ls
    {map, filter, slice, lines, any, fold, Str} = require 'prelude-ls'
    # DOM building function from React
    {i, div, tr, td, span, kbd, button, ul, li, a, h1, h2, h3, input, form, table, th, tr, td, thead, tbody, label, nav, p, ruby, rt} = React.DOM

    dboard = {}

    dboard.SourceModel = Backbone.Model.extend do
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


    dboard.SourcesCollection = Backbone.Collection.extend do
        url: ->
          '/source'
        model: dboard.SourceModel

        parse: (data) ->
          data.sources


    dboard.AbstractGridDashboard =
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


    # default waiting dashboard
    dboard.WaitDashboard = React.create-class do
      render: ->
        div {className: "ui active dimmer"},
          div {className: "ui loader"}


    dboard.DBoardApp = React.create-class do
      url: ->
        'http://' + document.domain + ':' + location.port + "/dash"

      # list all available dashboards
      dashboards:
        wait: dboard.WaitDashboard {}
  
      # alls data sources
      sources: new dboard.SourcesCollection []

      getInitialState: ->
        dash: \wait

      componentWillMount: ->
        console.log "<dboard app mounted>"
        console.log @props
        # fetch sources
        @sources.fetch do
          success: @createAppDashboards.bind @
        # connect on dashboard change from server
        @socket = io.connect @url!
        # update model when data are send on msg "change"
        @socket.on \update @dashUpdated.bind @
        if @props.debug
          window.sources = @sources
          window.dashboards = @dashboards

      createAppDashboards: ->
        #call external function
        dash = @props.dboardBuilder(@sources, @dashboards)
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
    
    # return dboard object
    dboard

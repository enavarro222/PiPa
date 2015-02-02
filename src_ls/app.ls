define do
  [ \jquery \react 'prelude-ls' \backbone \gridster \io \moment]
  ($, React, Prelude, Backbone, Gridster, io, moment) ->
    # Advanced functional style programming using prelude-ls
    {map, filter, slice, lines, any, fold, Str} = require 'prelude-ls'
    # DOM building function from React
    {i, div, tr, td, span, kbd, button, ul, li, a, h1, h2, h3, input, form, table, th, tr, td, thead, tbody, label, nav, p, ruby, rt} = React.DOM

    # Config de Cello
    DEBUG = true


    SourceModel = Backbone.Model.extend do
      name: "source"

      defaults:
        label: null
        value: 42
        unit: null

      url: ->
        'http://' + document.domain + ':' + location.port + "/source/" + @name

      initialize: (attr, options) ->
        @name = options.name || @name
        @socket = io.connect(@url!);
        # update model when data are send on msg "change"
        @socket.on \update (@set).bind @
        @fetch!
        @


    TitleBar = React.create-class do
      render: ->
        div {className: 'ui menu navbar page grid'},
          div {className: \container},
            div {className: 'title item'},
              "Info diverses"
            div {className: "right menu"},
              a {className: "item", href:\#},
                "À propos"


    TextGauge = React.create-class do
      componentWillMount: ->
        @props.model.on \change, @modelChanged

      componentWillUnmount: ->
        @props.model.off \change, @modelChanged

      modelChanged: !->
        @forceUpdate null

      render: ->
        div {className: 'ui center aligned segment swidget'},
          if @props.model.get \icon
            div {className: 'ui huge header'},
              i {className: 'huge icon ' + @props.model.get \icon}
          div {className: 'ui large header'},
            @props.model.get \value
            if @props.model.get \unit
              span {},
                ' '
                @props.model.get \unit
          if @props.model.get \label
            p {className: 'ui huge header'},
              @props.model.get \label


    TimeDate = React.create-class do
      getInitialState: ->
        time: moment().format('HH:mm:ss')
        date: moment().lang('fr').format('dddd D MMMM')

      updateDate: ->
        @setState do
          time: moment().format('HH:mm:ss')
          date: moment().lang('fr').format('dddd D MMMM')
        @timeout = setTimeout (@updateDate).bind @, 1000

      componentWillMount: ->
        @updateDate!

      componentWillUnmount: ->
        clearTimeout(@timeout)

      render: ->
        div {className: 'ui center aligned segment swidget'},
          div {className: 'ui huge header'},
            @state.time
          div {className: 'ui medium header'},
            @state.date

    WeekNum = React.create-class do
      getInitialState: ->
        week: moment().format('W')

      updateDate: ->
        @setState do
          week: moment().format('W')
        @timeout = setTimeout (@updateDate).bind @, 1000

      componentWillMount: ->
        @updateDate!

      componentWillUnmount: ->
        clearTimeout(@timeout)

      render: ->
        div {className: 'ui center aligned segment swidget'},
          div {className: 'ui medium header'},
            "semaine"
          div {className: 'ui huge header'},
            @state.week


    # definition des sources de données
    sources =
      count: new SourceModel {}, {name: "count"}
      cpu: new SourceModel {}, {name: "cpu"}

    if DEBUG
      window.sources = sources

    AppMain = React.create-class do
      render: ->
        div {className: 'gridster'},
          ul {ref: 'maingrid'},
            li {'data-row': 1, 'data-col': 1, 'data-sizex': 2, 'data-sizey': 1},
              TimeDate {}
            li {'data-row': 1, 'data-col': 1, 'data-sizex': 1, 'data-sizey': 1},
              WeekNum {}
            li {'data-row': 1, 'data-col': 3, 'data-sizex': 1, 'data-sizey': 1},
              TextGauge {model: sources.count}
            li {'data-row': 1, 'data-col': 4, 'data-sizex': 1, 'data-sizey': 1},
              TextGauge {model: sources.cpu}

      componentDidMount: ->
        ($ @refs.maingrid.getDOMNode!).gridster do
          'widget_margins': [10, 10]
          'widget_base_dimensions': [140, 140]
          'max_cols': 15
          'min_cols': 1

    # returned value: just the main component
    AppMain

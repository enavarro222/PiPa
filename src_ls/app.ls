define do
  [ \jquery \react 'prelude-ls' \backbone \io]
  ($, React, Prelude, Backbone, io) ->
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
        div {className: 'ui three wide column'},
          div {className: 'ui center aligned segment swidget'},
            if @props.model.get \icon
              p {className: 'ui huge header'},
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

    # definition des sources de données
    sources =
      count: new SourceModel {}, {name: "count"}
      cpu: new SourceModel {}, {name: "cpu"}

    if DEBUG
      window.sources = sources

    AppMain = React.create-class do
      render: ->
        div {className:'ui sidebar'},
          null
        div {className:'ui pusher mainpage'},
          div {className: 'ui page grid'},
            TextGauge {model: sources.count}
            TextGauge {model: sources.cpu}

    # returned value: just the main component
    AppMain

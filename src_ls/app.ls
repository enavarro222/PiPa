define do
  [ \jquery \react 'prelude-ls' \backbone \io]
  ($, React, Prelude, Backbone, io) ->
    # Advanced functional style programming using prelude-ls
    {map, filter, slice, lines, any, fold, Str} = require 'prelude-ls'
    # DOM building function from React
    {i, div, tr, td, span, kbd, button, ul, li, a, h1, h2, h3, input, form, table, th, tr, td, thead, tbody, label, nav, p, ruby, rt} = React.DOM

    # Config de Cello
    DEBUG = true

    ValueModel = Backbone.Model.extend do
      defaults:
        desc: "value"
        value: 44

      url: 'http://' + document.domain + ':' + location.port + "/model"

      initialize: (attr, options) ->
        @socket = io.connect(@url);
        # update model when data are send on msg "change"
        @socket.on \update (@set).bind @
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
      componentDidMount: ->
        @props.model.on \change, @modelChanged

      modelChanged: !->
        @forceUpdate null

      render: ->
        div {className: 'ui label'},
          @props.model.get \desc
          " :"
          div {className:'detail'}
            @props.model.get \value


    AppMain = React.create-class do
      vmodel: new ValueModel null
      render: ->
        if DEBUG
          window.vmodel = @vmodel
        div {className:'ui pusher'},
          TitleBar null
          div {className: 'ui page grid'},
            div {className: 'column'},
              TextGauge {model: @vmodel}

    # returned value: just the main component
    AppMain

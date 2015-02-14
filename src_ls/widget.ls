define do
  [ \jquery \react 'prelude-ls' \backbone \io \moment \d3]
  ($, React, Prelude, Backbone, io, moment, d3) ->
    # Advanced functional style programming using prelude-ls
    {map, filter, slice, lines, any, fold, Str} = require 'prelude-ls'
    # DOM building function from React
    {i, div, tr, td, span, kbd, button, ul, li, a, h1, h2, h3, input, form, table, th, tr, td, thead, tbody, label, nav, p, ruby, rt, svg, g, path, text} = React.DOM

    widget = {}
    window.React = React

    widget.CircleGauge = React.create-class do
      delta: Math.PI/7.5    # angle en plus de horisontal

      getDefaultProps: ->
        min: 0
        max: 1

      componentWillMount: ->
        @angle = d3.scale.linear!
          .domain [@props.min, @props.max] 
          .range [- @delta - Math.PI/2, @delta + Math.PI/2]
        @props.model.on \change, @modelChanged.bind @

      componentWillUnmount: ->
        @props.model.off \change, @modelChanged.bind @

      modelChanged: !->
        @renderSvg!

      render: ->
        div {className: 'ui center aligned segment swidget'},
          svg {ref: "gauge"},
            g {},
              text {ref: "gaugeText"}
              path {ref: "gaugeBackground"}
              path {ref: "gaugeItSelf"}

      renderSvg: ->
        parent = ($ @getDOMNode!).parent!
        w = parent.width!
        h = parent.height!
        rOut = 0.8 * Math.min w, h / 2
        rIn = 0.6 * rOut
        console.log w, h

        svgg = d3.select @refs.gauge.getDOMNode!
            .attr "width", w
            .attr "height", h
            .select "g"
            .attr "transform", "translate(" + (w / 2) + "," + (h / 2) + ")"


        d3.select @refs.gaugeText.getDOMNode!
            .text (@props.model.get \value) + " " + (@props.model.get \unit)
            .attr "transform", "translate(" + 0 + "," + (h / 4) + ")"
            .attr "text-anchor", "middle"
            .attr "alignment-baseline", "middle"
            .attr "font-family", "Lato, 'Helvetica Neue', Arial, Helvetica, sans-serif;"
            .attr "font-size", "1.78em"
            .attr "font-weight", "bold"
            .attr "fill", "black"

        bgArc = d3.svg.arc!
          .innerRadius rIn
          .outerRadius rOut
          .startAngle @angle @props.min
          .endAngle @angle @props.max

        d3.select @refs.gaugeBackground.getDOMNode!
          .attr "fill", (d, i) ->
            d3.rgb("black");
          .attr "d", bgArc

        fgArc = d3.svg.arc!
          .innerRadius rIn
          .outerRadius rOut
          .startAngle @angle @props.min
          .endAngle Math.min (@angle (@props.model.get \value)), (@angle @props.max)

        d3.select @refs.gaugeItSelf.getDOMNode!
          .attr "fill", (d, i) ->
            d3.rgb("red");
          .attr "d", fgArc
        @

      componentDidMount: ->
        @renderSvg!


    widget.TextGauge = React.create-class do
      componentWillMount: ->
        @props.model.on \change, @modelChanged

      componentWillUnmount: ->
        @props.model.off \change, @modelChanged

      modelChanged: !->
        @forceUpdate null

      render: ->
        varient = ""
        if @props.model.get \error
          varient = "error "
        segClass = "ui center aligned #varient segment swidget"
        div {className: segClass},
          div {className: "swidgetContent"},
            if @props.icon
              div {className: 'ui huge header'},
                i {className: 'huge icon ' + @props.icon}
            div {className: 'ui large header'},
              @props.model.get \value
              if @props.model.get \unit
                span {},
                  ' '
                  @props.model.get \unit
            if @props.label
              @props.label
          if @props.model.get \error
            div {className: 'floating ui red label'},
              @props.model.get \error


    widget.TimeDate = React.create-class do
      getInitialState: ->
        time: moment().format('HH:mm:ss')
        date: moment().format('dddd D MMMM')

      updateDate: ->
        @setState do
          time: moment().format('HH:mm:ss')
          date: moment().format('dddd D MMMM')
        clearTimeout(@timeout)
        @timeout = setTimeout @updateDate, 1000

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


    widget.WeekNum = React.create-class do
      getInitialState: ->
        week: moment().format('W')

      updateDate: ->
        @setState do
          week: moment().format('W')
        clearTimeout(@timeout)
        @timeout = setTimeout @updateDate, 30*1000

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

    widget

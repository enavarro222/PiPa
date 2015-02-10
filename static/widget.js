(function(){
  define(['jquery', 'react', 'prelude-ls', 'backbone', 'io', 'moment', 'd3'], function($, React, Prelude, Backbone, io, moment, d3){
    var map, filter, slice, lines, any, fold, Str, i, div, tr, td, span, kbd, button, ul, li, a, h1, h2, h3, input, form, table, th, thead, tbody, label, nav, p, ruby, rt, svg, g, path, widget, __ref;
    __ref = require('prelude-ls'), map = __ref.map, filter = __ref.filter, slice = __ref.slice, lines = __ref.lines, any = __ref.any, fold = __ref.fold, Str = __ref.Str;
    __ref = React.DOM, i = __ref.i, div = __ref.div, tr = __ref.tr, td = __ref.td, span = __ref.span, kbd = __ref.kbd, button = __ref.button, ul = __ref.ul, li = __ref.li, a = __ref.a, h1 = __ref.h1, h2 = __ref.h2, h3 = __ref.h3, input = __ref.input, form = __ref.form, table = __ref.table, th = __ref.th, tr = __ref.tr, td = __ref.td, thead = __ref.thead, tbody = __ref.tbody, label = __ref.label, nav = __ref.nav, p = __ref.p, ruby = __ref.ruby, rt = __ref.rt, svg = __ref.svg, g = __ref.g, path = __ref.path;
    widget = {};
    window.React = React;
    widget.CircleGauge = React.createClass({
      getDefaultProps: function(){
        return {
          min: 0,
          max: 1
        };
      },
      componentWillMount: function(){
        this.angle = d3.scale.linear().domain([this.props.min, this.props.max]).range([1.1 * -Math.PI / 2, 1.1 * Math.PI / 2]);
        return this.props.model.on('change', this.modelChanged.bind(this));
      },
      componentWillUnmount: function(){
        return this.props.off.model('change', this.modelChanged.bind(this));
      },
      modelChanged: function(){
        this.renderSvg();
      },
      render: function(){
        return div({
          className: 'ui center aligned segment swidget'
        }, svg({
          ref: "gauge"
        }, g({}, path({
          ref: "gaugeBackground"
        }), path({
          ref: "gaugeItSelf"
        }))));
      },
      renderSvg: function(){
        var parent, w, h, rOut, rIn, bgArc, fgArc;
        parent = $(this.getDOMNode()).parent();
        w = parent.width();
        h = parent.height();
        rOut = 0.8 * Math.min(w, h / 2);
        rIn = 0.6 * rOut;
        console.log(w, h);
        d3.select(this.refs.gauge.getDOMNode()).attr("width", w).attr("height", h).select("g").attr("transform", "translate(" + w / 2 + "," + h / 2 + ")");
        bgArc = d3.svg.arc().innerRadius(rIn).outerRadius(rOut).startAngle(this.angle(this.props.min)).endAngle(this.angle(this.props.max));
        d3.select(this.refs.gaugeBackground.getDOMNode()).attr("fill", function(d, i){
          return d3.rgb("black");
        }).attr("d", bgArc);
        fgArc = d3.svg.arc().innerRadius(rIn).outerRadius(rOut).startAngle(this.angle(this.props.min)).endAngle(Math.min(this.angle(this.props.model.get('value')), this.angle(this.props.max)));
        d3.select(this.refs.gaugeItSelf.getDOMNode()).attr("fill", function(d, i){
          return d3.rgb("red");
        }).attr("d", fgArc);
        return this;
      },
      componentDidMount: function(){
        return this.renderSvg();
      }
    });
    widget.TextGauge = React.createClass({
      componentWillMount: function(){
        return this.props.model.on('change', this.modelChanged);
      },
      componentWillUnmount: function(){
        return this.props.model.off('change', this.modelChanged);
      },
      modelChanged: function(){
        this.forceUpdate(null);
      },
      render: function(){
        var varient, segClass;
        varient = "";
        if (this.props.model.get('error')) {
          varient = "error ";
        }
        segClass = "ui center aligned " + varient + " segment swidget";
        return div({
          className: segClass
        }, div({
          className: "swidgetContent"
        }, this.props.icon ? div({
          className: 'ui huge header'
        }, i({
          className: 'huge icon ' + this.props.icon
        })) : void 8, div({
          className: 'ui large header'
        }, this.props.model.get('value'), this.props.model.get('unit') ? span({}, ' ', this.props.model.get('unit')) : void 8), this.props.label ? this.props.label : void 8), this.props.model.get('error') ? div({
          className: 'floating ui red label'
        }, this.props.model.get('error')) : void 8);
      }
    });
    widget.TimeDate = React.createClass({
      getInitialState: function(){
        return {
          time: moment().format('HH:mm:ss'),
          date: moment().format('dddd D MMMM')
        };
      },
      updateDate: function(){
        this.setState({
          time: moment().format('HH:mm:ss'),
          date: moment().format('dddd D MMMM')
        });
        clearTimeout(this.timeout);
        return this.timeout = setTimeout(this.updateDate, 1000);
      },
      componentWillMount: function(){
        return this.updateDate();
      },
      componentWillUnmount: function(){
        return clearTimeout(this.timeout);
      },
      render: function(){
        return div({
          className: 'ui center aligned segment swidget'
        }, div({
          className: 'ui huge header'
        }, this.state.time), div({
          className: 'ui medium header'
        }, this.state.date));
      }
    });
    widget.WeekNum = React.createClass({
      getInitialState: function(){
        return {
          week: moment().format('W')
        };
      },
      updateDate: function(){
        this.setState({
          week: moment().format('W')
        });
        clearTimeout(this.timeout);
        return this.timeout = setTimeout(this.updateDate, 30 * 1000);
      },
      componentWillMount: function(){
        return this.updateDate();
      },
      componentWillUnmount: function(){
        return clearTimeout(this.timeout);
      },
      render: function(){
        return div({
          className: 'ui center aligned segment swidget'
        }, div({
          className: 'ui medium header'
        }, "semaine"), div({
          className: 'ui huge header'
        }, this.state.week));
      }
    });
    return widget;
  });
}).call(this);

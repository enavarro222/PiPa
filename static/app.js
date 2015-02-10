(function(){
  define(['jquery', 'react', 'prelude-ls', 'backbone', 'gridster', 'io', 'moment', 'widget'], function($, React, Prelude, Backbone, Gridster, io, moment, widget){
    var map, filter, slice, lines, any, fold, Str, i, div, tr, td, span, kbd, button, ul, li, a, h1, h2, h3, input, form, table, th, thead, tbody, label, nav, p, ruby, rt, DEBUG, SourceModel, sources, AppMain, __ref;
    __ref = require('prelude-ls'), map = __ref.map, filter = __ref.filter, slice = __ref.slice, lines = __ref.lines, any = __ref.any, fold = __ref.fold, Str = __ref.Str;
    __ref = React.DOM, i = __ref.i, div = __ref.div, tr = __ref.tr, td = __ref.td, span = __ref.span, kbd = __ref.kbd, button = __ref.button, ul = __ref.ul, li = __ref.li, a = __ref.a, h1 = __ref.h1, h2 = __ref.h2, h3 = __ref.h3, input = __ref.input, form = __ref.form, table = __ref.table, th = __ref.th, tr = __ref.tr, td = __ref.td, thead = __ref.thead, tbody = __ref.tbody, label = __ref.label, nav = __ref.nav, p = __ref.p, ruby = __ref.ruby, rt = __ref.rt;
    DEBUG = true;
    moment.locale("fr");
    SourceModel = Backbone.Model.extend({
      name: "source",
      defaults: {
        value: 42,
        unit: null,
        last_update: null,
        timeout: 60 * 3,
        outdated: false,
        error: null
      },
      url: function(){
        return 'http://' + document.domain + ':' + location.port + "/source/" + this.name;
      },
      initialize: function(attr, options){
        this.name = options.name || this.name;
        this.checkOutDatedTimeout = null;
        this.socket = io.connect(this.url());
        this.socket.on('update', this.newDataPushed.bind(this));
        this.fetch({
          success: this.checkOutDated.bind(this)
        });
        return this;
      },
      newDataPushed: function(data){
        console.log("new data", data);
        this.set(data);
        return this.checkOutDated();
      },
      checkOutDated: function(){
        var lastUpdate, timeout;
        clearTimeout(this.checkOutDatedTimeout);
        lastUpdate = moment(this.get('last_update'));
        if (lastUpdate.isValid()) {
          timeout = this.get('timeout');
          if (moment().diff(lastUpdate, 'second') > timeout) {
            this.set('outdated', true);
            this.set('error', lastUpdate.fromNow(true));
          } else {
            if (this.get('outdated')) {
              this.set('error', false);
            }
            this.set('outdated', false);
            this.checkOutDatedTimeout = setTimeout(this.checkOutDated.bind(this), Math.min(timeout, 15) * 1000);
          }
        }
        return this;
      }
    });
    sources = {
      count: new SourceModel({}, {
        name: "count"
      }),
      cpu: new SourceModel({}, {
        name: "cpu"
      }),
      extTemp: new SourceModel({}, {
        name: "ext_temp"
      }),
      extHum: new SourceModel({}, {
        name: "ext_hum"
      }),
      grangeTemp: new SourceModel({}, {
        name: "grange_temp"
      })
    };
    if (DEBUG) {
      window.sources = sources;
    }
    AppMain = React.createClass({
      render: function(){
        return div({
          className: 'gridster'
        }, ul({
          ref: 'maingrid'
        }, li({
          'data-row': 1,
          'data-col': 1,
          'data-sizex': 3,
          'data-sizey': 1
        }, div({
          className: 'ui segment grid swidget'
        }, div({
          className: 'ui ten wide column'
        }, widget.TimeDate({})), div({
          className: 'ui six wide column'
        }, widget.WeekNum({})))), li({
          'data-row': 1,
          'data-col': 4,
          'data-sizex': 1,
          'data-sizey': 1
        }, widget.TextGauge({
          model: sources.count,
          label: "count"
        })), li({
          'data-row': 1,
          'data-col': 5,
          'data-sizex': 1,
          'data-sizey': 1
        }, widget.TextGauge({
          model: sources.extTemp,
          label: span({
            className: 'ui small header'
          }, "Temp. ext.")
        })), li({
          'data-row': 1,
          'data-col': 6,
          'data-sizex': 1,
          'data-sizey': 1
        }, widget.TextGauge({
          model: sources.extHum,
          label: span({
            className: 'ui small header'
          }, "Hum. ext.")
        })), li({
          'data-row': 1,
          'data-col': 7,
          'data-sizex': 1,
          'data-sizey': 1
        }, widget.TextGauge({
          model: sources.grangeTemp,
          label: span({
            className: 'ui small header'
          }, "Temp. grange")
        })), li({
          'data-row': 1,
          'data-col': 8,
          'data-sizex': 1,
          'data-sizey': 1
        }, widget.TextGauge({
          model: sources.cpu,
          icon: "dashboard"
        })), li({
          'data-row': 2,
          'data-col': 1,
          'data-sizex': 2,
          'data-sizey': 2
        }, widget.CircleGauge({
          model: sources.cpu,
          icon: "dashboard",
          min: 0,
          max: 100
        })), li({
          'data-row': 3,
          'data-col': 1,
          'data-sizex': 1,
          'data-sizey': 1
        }, div({
          className: 'ui segment swidget'
        }, "TEST")), li({
          'data-row': 4,
          'data-col': 1,
          'data-sizex': 1,
          'data-sizey': 1
        }, div({
          className: 'ui segment swidget'
        }, "TEST")), li({
          'data-row': 4,
          'data-col': 3,
          'data-sizex': 1,
          'data-sizey': 1
        }, div({
          className: 'ui segment swidget'
        }, "TEST A")), li({
          'data-row': 4,
          'data-col': 7,
          'data-sizex': 1,
          'data-sizey': 1
        }, div({
          className: 'ui segment swidget'
        }, "TEST FIN"))));
      },
      componentDidMount: function(){
        var w, h, mw, mh;
        w = 145;
        h = 145;
        mw = 10;
        mh = 10;
        this.grid = $(this.refs.maingrid.getDOMNode()).gridster({
          'widget_margins': [mw, mh],
          'widget_base_dimensions': [w, h],
          'max_cols': 8,
          'min_cols': 8
        }).data('gridster');
        this.grid.disable();
        return $(this.refs.maingrid.getDOMNode()).find("li").each(function(i, li){
          var sizex, sizey, widgetW, widgetH;
          sizex = $(li).attr("data-sizex");
          sizey = $(li).attr("data-sizey");
          widgetW = w * sizex + 2 * mw * (sizex - 1);
          widgetH = h * sizey + 2 * mh * (sizey - 1);
          return $(li).first().children().first().width(widgetW).height(widgetH);
        });
      }
    });
    return AppMain;
  });
}).call(this);

(function(){
  require.config({
    paths: {
      jquery: ['/static/lib/jquery-1.11.0.min'],
      underscore: '/static/lib/underscore-min',
      backbone: '/static/lib/backbone-min',
      backbone_forms: '/static/lib/backbone-forms.min',
      'prelude-ls': '/static/lib/prelude-browser-min',
      react: ['/static/lib/react-0.12.2'],
      'backbone-react': '/static/lib/backbone-react-component-min',
      semantic: '/static/lib/semantic/semantic.min',
      gridster: '/static/lib/jquery.gridster.min',
      io: '/static/lib/socket.io-0.9.16.min',
      moment: '/static/lib/moment-with-locales.min',
      d3: '/static/lib/d3.v3.min'
    },
    shim: {
      semantic: {
        deps: ['jquery']
      }
    }
  });
  require(['react', 'app'], function(React, AppMain){
    return React.render(React.createElement(AppMain), document.getElementById("main"));
  });
}).call(this);

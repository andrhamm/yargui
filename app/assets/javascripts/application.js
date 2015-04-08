// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_tree .
//= require paloma
//= require websocket_rails/main
//= require underscore
//= require jquery.terminal-0.8.8
//= require jquery.dynatable

var ApplicationController = Paloma.controller('Application');

// Executes when Rails User#new is executed.
ApplicationController.prototype.home = function(){
  jQuery(function($, undefined) {
    var dispatcher = new WebSocketRails('localhost:3000/websocket');

    dispatcher.on_open = function(data) {
      console.log('Connection has been established: ', data);
      // You can trigger new server events inside this callback if you wish.
    }

    $('#browser').dynatable();
    var table = $('#browser').data('dynatable');

    var term = $('#terminal').terminal({
      redis: function (string) {
        console.log('command: redis, string: ' + string);
        var opts = {}
        opts.string = string;
        term.pause();
        dispatcher.trigger('redis_call', opts, function(response){
          console.log('Server triggered success');
          console.log(response);
          if (response.response && response.response.length) {
            term.echo("[[i;green;]\t=> " + JSON.stringify(response.response) + "\n]");
          }
          term.resume();
        }, function(response){
          console.log('Server triggered failure');
          console.log(response);
          term.error(response.message);
          term.resume();
        })
      }
    }, {
        greetings: "[[bui;yellow;]Yet Another Redis GUI] - [[bi;magenta;]by @andrhamm]",
        height: 200,
        prompt: 'yargui> ',
        processArguments: function(command) {
          return [command];
        },
        tabcompletion: true,
        completion: function(terminal, string, callback) {
          console.log('Getting tab completion event ' + string);
          var search_opts = {}
          search_opts.string = string;

          dispatcher.trigger('key_tab_complete', search_opts, function(response){
            console.log('Server triggered success');
            console.log(response);
            callback(response.keys);
          }, function(){
            console.log('Server triggered failure');
            callback([]);
          })
        }
    });

    dispatcher.bind('all_keys', function(keyArr){
      console.log('Got all keys from server: ', keyArr);

      table.records.updateFromJson({
        records: keyArr
      });

      table.dom.update();

      term.echo('[[i;darkgray;]table updated with ' + keyArr.length + ' keys]');
    });

    dispatcher.bind('keys', function(data){
      console.log('Got subset of keys from server: ', data);

      table.records.updateFromJson({
        records: data.keys
      });

      table.dom.update();

      term.echo('[[i;darkgray;]table updated with ' + data.keys.length + ' keys]');
    });

    dispatcher.bind('key', function(data){
      console.log('Got single key details from server: ', data);
      summary = ""
      pairs = _.pairs(data)
      for (var i = 0; i < pairs.length; i++ ) {
        summary += pairs[i].join(': ') + "  "
      }
      if (summary.length) {
        term.echo("[[i;green;]\t=> " + summary + "\n]");
      }
    });
  });
};


// See https://gist.github.com/louisremi/1114293#file_anim_loop_x.js
// Cross browser, backward compatible solution
(function( window, Date ) {
// feature testing
var raf = window.mozRequestAnimationFrame    ||
          window.webkitRequestAnimationFrame ||
          window.msRequestAnimationFrame     ||
          window.oRequestAnimationFrame;

window.animLoop = function( render, element ) {
  var running, lastFrame = +new Date;
  function loop( now ) {
    if ( running !== false ) {
      raf ?
        raf( loop, element ) :
        // fallback to setTimeout
        setTimeout( loop, 16 );
      // Make sure to use a valid time, since:
      // - Chrome 10 doesn't return it at all
      // - setTimeout returns the actual timeout
      now = now && now > 1E4 ? now : +new Date;
      var deltaT = now - lastFrame;
      // do not render frame when deltaT is too high
      if ( deltaT < 160 ) {
        running = render( deltaT, now );
      }
      lastFrame = now;
    }
  }
  loop();
};
})( window, Date );

$(document).ready(function() {
  (function Editor() {

    var editor = ace.edit("editor");
    editor.setReadOnly(true);
    editor.setTheme("ace/theme/github");
    editor.getSession().setMode("ace/mode/ruby");
    this.editor = editor;

    this.typeCode = function(text, finalPause) {
      var deferred = new $.Deferred();
      var textArr = text.split('');

      var interval = 1000/25; // 25 fps
      var now;
      var then = Date.now();
      var delta;

      animLoop(function (deltaT, now) {
        now = Date.now();
        delta = now - then;

        if (delta > interval) { // limit fps
          var nextChar = textArr.shift();

          if (typeof nextChar === "undefined") {
            setTimeout(function() {
              deferred.resolve();
            }, finalPause);
            // return false; will stop the loop
            return false;
          } else {
            editor.insert(nextChar);
            then = now - (delta % interval);
          }
        }
      });
      return deferred;
    }

    var demoEditor = this;
    function clearEditor() {
      var deferred = new $.Deferred();
      editor.setValue("")
      deferred.resolve();
      return deferred;
    }
    var animationFrames = [
      function() { return demoEditor.typeCode("# Welcome to Pacto\n# We're going to show you some basic usage here", 1000) },
      clearEditor,
      function() { return demoEditor.typeCode("# First, add Pacto to your Gemfile\n\ngem 'pacto'\n", 1000) }
      // ,
      // function() {
      //   var deferred = new $.Deferred();
      //   panel = $("<div class=\"bubble\"></div>");
      //   panel.height($("#editor-section").height());
      //   panel.append("<h4>And then...</h4>");
      //   panel.append("<p>bundle install</p>");
      //   $("#comments-container").append(panel).addClass('animated slideInRight');
      //   deferred.resolve();
      //   return deferred;
      // }
    ];

    function runAnimation() {
      var frame = animationFrames.shift();
      if (typeof frame === "undefined") {
        return
      } else {
        console.log("Running a frame");
        frame().promise().done(runAnimation);
      }
    };
    runAnimation();
  })();
});

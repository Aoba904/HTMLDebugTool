// Generated by CoffeeScript 1.6.3
(function() {
  var sys,
    _this = this;

  sys = $eg.space("UI");

  sys.include($eg.Extender).method("execute", function() {
    return (new sys.Main).execute();
  }).Class("Main").extend(sys.Singleton).def({
    init: function() {
      return this.message = "HelloWorld";
    },
    execute: function() {
      return console.log(this.message);
    }
  });

}).call(this);

/*
//@ sourceMappingURL=index.map
*/

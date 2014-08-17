var express = require('express');
var router = express.Router();

var fs = require('fs'),
    path = require('path'),
    moment = require('moment');


/* polyfil for v8 engine */
if (!Number.isInteger) {
  Number.isInteger = function isInteger (nVal) {
    return typeof nVal === "number" && isFinite(nVal) && nVal > -9007199254740992 && nVal < 9007199254740992 && Math.floor(nVal) === nVal;
  };
}



var Status = function(hash){
  var self = this;
  this.hash = hash;
  this.fileLog = path.join(__dirname, '../logs/', this.hash+'.log');
  this.logger = [];
  this.active = false;
};

Status.prototype = {
  logs: function(nth, callback) {
    
    if (!Number.isInteger(nth)) {
      nth = 10;
    }
    if (this.logExists() == false) {

      return callback([]);
    }
    this._readFile(nth, function(array){
      return callback(array);
    });


  },
  isActive: function(callback) {
    var self = this;

    fs.exists(this.fileLog, function(exists) {
      exists = exists ? true : false;
      if (exists == true) {
        fs.stat(self.fileLog, function(err, stats) {
          if (err) {
            return callback(false);
          };
          var mt = moment(stats.mtime).format("X"),
              now = moment().format("X");
          if ((now - mt) < 300) {
            return callback(true);
          } else {
            return callback(false);
          };
        });
      } else {
        return callback(false);
      }
    });

  },
  _readFile: function(nth, callback) {

    fs.readFile(this.fileLog, {flag: 'r', encoding: "UTF-8"}, function (err, data) {
      if (err) throw err;
      data = data.split("\n").reverse();
      data = data.splice(0, nth);
      return callback(data);
    });
  },
  logExists: function() {
    return fs.existsSync(this.fileLog, function(exists) {
      return exists ? true : false;
    });

  }
};


router.get('/:hash', function(req,res) {

  var user = new Status(req.params.hash);
  user.logs(10, function(logger){
    //something weird going on here, so set it in logger
    user.logger = logger;
    user.isActive(function(active) {
      user.active = active;
      res.render('status', user);
    });

    

    
  })
  

});


module.exports = router;

var express = require('express');
var router = express.Router();

var fs = require('fs'),
    spawn = require('child_process').spawn,
    crypto = require('crypto'),
    path = require('path'),
    moment = require('moment');


var Process = function(params){
  var self = this;

  this.params = {};
  this.params.from = {
    email: this._valid(params.from.email),
    password: this._valid(params.from.password),
    usessl: this._valid(params.from.usessl),
  };
  this.params.to = {
    server: this._valid(params.to.server),
    email: this._valid(params.to.email),
    password: this._valid(params.to.password),
    usessl: this._valid(params.to.usessl),
  };

  this.id = this.hash = this._hash();
  this.fileLog = path.join(__dirname, '../logs/', this.hash+'.log');

  //test the status before we excute
  this.isActive(function(status) {
    if (!status) {
      //set options that we will use.
      self._setOptions();
      //execute the process.. if we made it this far.
      self._execute();
    }
  });
 
}

Process.prototype = {
  _setOptions: function() {
    this.options = [
      '--host1', '127.0.0.1' ,
      '--user1', this.params.from.email, 
      '--password1', this.params.from.password,
      '--host2', this.params.to.server,
      '--user2', this.params.to.email, 
      '--password2', this.params.to.password
    ];

    if (this.params.from.usessl == true) {
      this.options.push('--ssl1');
    };
    if (this.params.to.usessl == true) {
      this.options.push('--ssl2');
    };

    this.options.push('--debug');
    this.options.push('--sep2');
    this.options.push('/');
    this.options.push('--delete');
    this.options.push("--prefix2");
    this.options.push("");

  },
  detach: function() {
    // this.child.unref();
  },
  isActive: function(callback) {
    var self = this;

    fs.exists(this.fileLog, function(exists) {
      exists = exists ? true : false;
      if (exists) {
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
  _valid: function(inputstring) {
    var spacetest = inputstring || "";
    if (spacetest === "true") {
      return true;
    } else if(spacetest === "false") {
      return false;
    }

    var spacetest = spacetest.match(/^([a-zA-Z0-9@(.|\n)\+_-]+)/) || [];
    if (spacetest.length == 2) {
      return spacetest[1];
    }
    console.log("Failed the space test");
    return null;
  },
  _hash: function() {
    var sha256 = crypto.createHash("sha1");
    sha256.update(this.params.from.email);
    return sha256.digest('hex');
  },
  _execute: function() {
    this.out = fs.openSync(this.fileLog, 'a');
    this.err = fs.openSync(this.fileLog, 'a');
    this.child = spawn('./imapsync/imapsync', this.options, {
      detached: false,
      stdio: [ 'ignore', this.out, this.err ]
    }); 
  }
}



router.post('/', function(req, res) {
  var P1 = new Process(req.body);
  P1.isActive(function(status) {

    if (status == true) {
      res.send({url:"/status/"+P1.id});

    } else {
      res.send({url:"/status/"+P1.id});

    }
  });

  
});

module.exports = router;
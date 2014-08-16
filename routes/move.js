var express = require('express');
var router = express.Router();



var fs = require('fs'),
    spawn = require('child_process').spawn,
    crypto = require('crypto'),
    path = require('path'); 


var Process = function(params){
  this.params = {};
  this.params.from = {
    email: this._valid(this.params.from.email),
    password: this._valid(this.params.from.password)
  };
  this.params.to = {
    server: this._valid(this.params.to.server),
    email: this._valid(this.params.to.email),
    password: this._valid(this.params.to.password),
  };

  this.hash = this._hash();
  var fileLog = path.join(__dirname, '/logs/', this.hash+'.log');
  this.out = fs.openSync(fileLog, 'a');
  this.err = fs.openSync(fileLog, 'a');


  this.options = [
    '--host1', '127.0.0.1' ,
    '--user1', this.params.from.email, 
    '--password1', this.params.from.password,
    '--host2', this.params.to.server,
    '--user2', this.params.to.email, 
    '--password2', this.params.to.password
  ];

  if (this.params.to.usessl == 'true') {
    this.options.push('--ssl2');
  }

  this.options.push('--debug');
  this.options.push('--sep2');
  this.options.push('/');
  this.options.push("--prefix2");
  this.options.push("");


  // this.child = spawn('./imapsync/imapsync', this.options, {
  //   detached: false,
  //   stdio: [ 'ignore', this.out, this.err ]
  // });  
}

Process.prototype = {

  detach: function() {
    // this.child.unref();
  },
  status: function() {

  },
  _valid: function(test) {
    var spacetest = test.match(/^([a-zA-Z0-9@(.|\n)\+_-]+)/) || [];
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
  }

}

Process.valid = function(val) {

}


/* GET users listing. */
router.post('/', function(req, res) {
  var P1 = new Process(req.body).detach();
  res.render('move');
});

module.exports = router;
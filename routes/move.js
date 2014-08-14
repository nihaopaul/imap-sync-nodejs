var express = require('express');
var router = express.Router();



var fs = require('fs'),
    spawn = require('child_process').spawn,
    crypto = require('crypto'); 




 


var Process = function(params){
  this.params = params;
  this.hash = this._hash();
  this.out = fs.openSync('./logs/'+this.hash+'.log', 'a');
  this.err = fs.openSync('./logs/'+this.hash+'.log', 'a');
  this.child = spawn('./imapsync/imapsync', [
      '--host1', 'mrchaos.chaos-studio.com' ,
      '--user1', params.from.email, 
      '--password1', params.from.password,
      '--host2', 'imap.chaos-studio.com' ,
      '--user2', params.to.email, 
      '--password2', params.to.password,
      '--debug', '--ssl2', '--sep2', '/', "--prefix2", ""
      ], {

    detached: false,
    stdio: [ 'ignore', this.out, this.err ]
  });
  
}
Process.prototype = {
  detach: function() {
    // this.child.unref();
  },
  status: function() {

  },
  _hash: function() {
    var sha256 = crypto.createHash("sha1");
    sha256.update(this.params.from.email);
    return sha256.digest('hex');
  }

}


/* GET users listing. */
router.post('/', function(req, res) {
  var P1 = new Process(req.body).detach();
  res.render('move');
});

module.exports = router;
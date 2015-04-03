//var vm = require('vm');
var fs = require('fs');
var path = require('path');

var dir = path.dirname(require.main.filename)+'\\json';

var files = fs.readdirSync(dir);
for (var js in files)
  console.log(files[js]);

/*
fs.readFile('./airstest.js', function(e, data) {
  if (e) {throw e;}
  var context= {require:require, console:console, process:process};
  //process.argv[2] = "select * from svod_code limit 1;";
  console.log('\n./airstest.js "' + process.argv[2] + '"');
  process.stdout.write = function(d){process.stderr.write(d)};
  vm.runInNewContext(data.toString(), context);
});
*/
process.stdout.write = function(d){process.stderr.write('+++'+d+'+++')};
require('./airstest.js');
delete require.cache[require.resolve('./airstest.js')];
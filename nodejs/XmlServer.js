// Load the http module to create an http server.
var http = require('http');
var open = require('open');
var url = require("url");
var mysql = require('mysql');
var path = require('path');
var fs = require('fs');
//var vm = require('vm');

var old_write = process.stdout.write;
var dir = path.dirname(require.main.filename);

var connection = mysql.createConnection({
  host: 'ec2-54-208-78-75.compute-1.amazonaws.com',
  user: 'userairs',
  password: 'userairs',
	database : 'airs'
});
connection.connect();

var server = http.createServer(function (request, response) {
  process.stdout.write = old_write;
  var pathname = decodeURIComponent(url.parse(request.url).pathname);
  var mpath = pathname.split('/');
  var sql = "select 1 one";
  console.log("Request for '" + pathname + "' received.");
  console.log(mpath);
  
  if(pathname==='/kill/'){
    response.writeHead(200, {"Content-Type": "text/html; charset=UTF-8"});
    console.log("Server killed.");
    response.end("<h1>Server Убили !!! killed<h1> <hr> \
      Start: <a href='/" + process.argv[1] +"'>" + process.argv[1] + "</a> \
    ");
    request.connection.destroy();
    process.exit();
  }
  
  if(mpath[1]==='sql2xml'){
    if(mpath.length>2) if(mpath[2]!=='') sql= mpath[2];
    console.log('\nsql2xml: '+ sql);
    response.writeHead(200, {"Content-Type": "text/xml; charset=UTF-8"});
    response.write("<?xml version='1.0' encoding='UTF-8'?> \
      <ROWSET autor='is10-99' versionOf='2015-03-15'> \
    ");

    response.write("<!--\n" +process.argv[1]+ "\n+\n" + sql+ "\n-->");
    connection.query(sql, function(err, rows, fields) {
      if (err) {
        console.log(err);
        response.write("<error> <![CDATA[" +err+ " ]]></error>");
      } else
      for(var r in rows){
        var row = rows[r];
        response.write("<ROW>\n");
        for(var k in row){
          response.write("<" +k+ ">");
          response.write("<![CDATA[" +row[k] +"]]>");
          response.write("</" +k+ ">\n");
        }
        response.write("</ROW>\n")
      }
      response.end("</ROWSET>");
    });
    return;
  }

  if(mpath[1]==='sql2json'){
    if(mpath.length>2) if(mpath[2]!=='') sql= mpath[2];
    response.writeHead(200, {"Content-Type": "application/json; charset=UTF-8"});
    console.log('\nsql2json: '+ sql);
    response.write("[{\"autor\":\"is10-99\", \"script\":" +
      "\"" + process.argv[1].replace(/\\/g, "\\\\") + "\", \"SQL\":\"" +sql+ "\"\n");

    connection.query(sql, function(err, rows, fields) {
      if (err) {
        console.log(err);
        response.write(",\"error\": \"" +err+ "\" }]\n");
      } else {
        response.write("}\n,\n");
        response.write(JSON.stringify(rows));
        response.write("]")
      };
      response.end();
    });
    return;
  }

  if(mpath[1]==='cgi-json'){
    var jsfile = dir + '\\json\\' + mpath[2];
    fs.readFile(jsfile, function(e, data) {
      if (e) {throw e;}
      response.writeHead(200, {"Content-Type": "application/json; charset=UTF-8"});
      process.argv.splice(2, 100);
      if(mpath.length>3) {
        process.argv[2] = mpath[3];
        console.log(jsfile + ' "' + mpath[3] + '"')
      } else 
        console.log(jsfile);
      process.stdout.write = function(d){response.write(d)};
      /*
      var context= {require:require, console:console, process:process};
      vm.runInNewContext(data.toString(), context);      
      //response.end();
      */
      require(jsfile);
      delete require.cache[require.resolve(jsfile)];
    });
    return;
  }

  response.writeHead(200, {"Content-Type": "text/html; charset=UTF-8"});
  response.write('<div style="font-size:24">');
  response.write("<h2>Node.js XML server</h2><h3>"+pathname+"</h3><hr><ui>");
  response.write("<li><a href='/sql2xml/show tables'  target='_blank'>/sql2xml/...</a>");
  response.write("<li><a href='/sql2json/show tables'  target='_blank'>/sql2json/...</a>");
  response.write("<li><a href='/kill/'>/kill</a>");
  response.write('</ui>');

  response.write('<hr><ui>');
  var files = fs.readdirSync(dir + '\\json');
  for (var js in files){
    response.write('<li><a href="/cgi-json/'+files[js]+'" target="_blank">/cgi-json/'+files[js]+'</a>');
  }
  response.write('<hr><ui>');
  files = fs.readdirSync(dir + '\\xml');
  for (var js in files){
    response.write('<li><a href="/cgi-xml/'+files[js]+'" target="_blank">/cgi-xml/'+files[js]+'</a>');
  }
  response.write('</ui></div>');

  response.end();
});

server.listen(9000);

console.log("\n\nServer running at http://127.0.0.1:9000/");
console.log(process.argv);
if (process.argv.length===2)
  open('http://127.0.0.1:9000/Starting ' + process.argv[1]);

// Load the http module to create an http server.
var http = require('http');
//var open = require('open');
var url = require("url");

// Configure our HTTP server to respond with Hello World to all requests.
var server = http.createServer(function (request, response) {
  var pathname = decodeURIComponent(url.parse(request.url).pathname);  
  console.log("Request for '" + pathname + "' received.");
  response.writeHead(200, {"Content-Type": "text/html; charset=UTF-8"});
  if(pathname==='/kill/'){
    console.log("Server killed.");
    response.end("<h1>Server killed<h1>");
    request.connection.destroy();
    process.exit();
  }  
  response.write('<div style="font-size:24">');
  response.write("<h1>"+pathname+"</h1>");
  response.write("<hr><a href='http://127.0.0.1:9000/kill/'>Kill server</a>");
  response.write('</div>');
  response.end();
});

// Listen on port 8000, IP defaults to 127.0.0.1
//server.listen(9000);
server.listen(8080);

// Put a friendly message on the terminal
console.log("Server running at http://127.0.0.1:8080/");
//open('http://127.0.0.1:9000/'+ 'Hello World');

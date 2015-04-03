http = require "http"
open = require "open"
url = require "url"

scriptname = process.argv[1]

server = http.createServer (request, response)->
  pathname = decodeURIComponent (url.parse request.url).pathname
  search = decodeURIComponent (url.parse request.url,true).search
  if not search then search = ''
  console.log "Request for '#{pathname}#{search}' received."
  response.writeHead 200, "Content-Type": "text/html; charset=UTF-8"
  
  if pathname =='/kill/'
    response.end "<h1>кирдык '#{scriptname}'</h1>"
    server.close ''
    request.connection.destroy ''
    console.log "кирдык '#{scriptname}'"
    process.exit ''
    return
  
  response.end """<div style='font-size:20'>
  <h2>#{scriptname}: echo & suicide server</h2>
  <h2>#{pathname}#{search}</h2>
  <hr><a href='/kill/''>Kill server</a>
  </div>"""

.listen 9002

console.log "#{scriptname} running at http://127.0.0.1:9002/"
open 'http://127.0.0.1:9002/Hello World?Вася&Петя'

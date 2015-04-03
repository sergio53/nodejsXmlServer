http = require 'http'
open = require 'open'
url = require 'url'
mysql = require 'mysql'
path = require 'path'
fs = require 'fs'

old_write = process.stdout.write
dir = path.dirname require.main.filename
srvname = process.argv[1]
versionOf = fs.statSync(srvname).mtime.toISOString()[..9]

connection = mysql.createConnection
  host: 'ec2-54-208-78-75.compute-1.amazonaws.com'
  user: 'userairs'
  password: 'userairs'
  database : 'airs'


server = http.createServer (request, response)->
  process.stdout.write = old_write
  pathname = decodeURIComponent(url.parse(request.url).pathname)
  search = decodeURIComponent (url.parse request.url,true).search  
  console.log "Request for '#{pathname}#{search}' received."
  if not search then search = '' else  search = search[1..]
  mpath = pathname.split '/'
  console.log mpath
  sql = 'select 1 one'
  
  if pathname =='/crossdomain.xml'
    response.writeHead 200, "Content-Type": "text/xml; charset=UTF-8"
    response.end """<?xml version="1.0"?>
      <cross-domain-policy>
        <allow-access-from domain="*" secure="false" />
      </cross-domain-policy>"""
    return    

  if pathname =='/kill/'
    response.writeHead 200, "Content-Type": "text/html; charset=UTF-8"
    response.end """<h1>Server кирдык<h1>
    <hr>
    Start: <a href='#{if srvname[0]=='/' then srvname else '/'+ srvname}'> #{srvname} </a>"""

    server.close ''
    request.connection.destroy ''
    console.log "кирдык '#{srvname}'"
    process.exit ''
    return
  
  if mpath[1] in ['cgi-json','cgi-xml']
    cof = path.join dir, mpath[1][4..], mpath[2]
    process.argv.splice 2, 100
    process.argv[1] = cof
    if search
      process.argv[2] = search
      console.log "#{cof} '#{search}'"
    else 
      console.log cof
    if mpath[1] =='cgi-json'
      response.writeHead 200, "Content-Type": "application/json; charset=UTF-8",
      "Access-Control-Allow-Origin": "*"
    else
      response.writeHead 200, "Content-Type": "text/xml; charset=UTF-8",
      "Access-Control-Allow-Origin": "*"
    
    ##!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    process.stdout.write = (d)-> 
      response.write d
    require cof
      .on '</ROWSET>', -> response.end ''
    delete require.cache[require.resolve cof]    
    #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    return  

  if mpath[1]=='sql2xml'
    if mpath.length>2
      if mpath[2]!='' then sql= mpath[2]
    console.log "\nsql2xml: #{sql}"
    response.writeHead 200, 
      "Content-Type": "text/xml; charset=UTF-8",
      "Access-Control-Allow-Origin": "*"
    response.write """<?xml version='1.0' encoding='UTF-8'?>
      <ROWSET autor='is10-99' versionOf='#{versionOf}'>
      <!-- #{srvname}
      /#{sql}
      -->
    """
    connection.query sql, (err, rows, fields)->
      if err
        console.log err
        response.write "<error> <![CDATA[#{err}]]></error>"
      else
        for row in rows
          response.write "<ROW>\n"
          for fild in fields
            response.write "<#{fild.name}><![CDATA[#{row[fild.name]}]]></#{fild.name}>"
          response.write "\n</ROW>\n"
      response.end "</ROWSET>"
    return

  if mpath[1]=='sql2json'
    if mpath.length>2
     if mpath[2]!='' then sql= mpath[2]
    response.writeHead 200, 
      "Content-Type": "application/json; charset=UTF-8", 
      "Access-Control-Allow-Origin": "*"
    console.log "\nsql2json: #{sql}"
    response.write """[{"autor":"is10-99", 
      "script":"#{srvname.replace(/\\/g, '\\\\')}", 
      "versionOf":"#{versionOf}",
      "/SQL":"#{sql}"
      """
    connection.query sql, (err, rows)->
      if err
        console.log err
        response.write ""","error": "#{err}"}]
        """
      else
        response.write "}\n,\n"
        response.write JSON.stringify rows
        response.write "]"
      response.end ''
    return

  ##===================================================================
  response.writeHead 200, "Content-Type": "text/html; charset=UTF-8"
  response.write """<div style="font-size:24">
  <h2>CoffeeScript XML server (#{versionOf}):</h2>   
  <h3>#{pathname}</h3>
  <ul><li><a href='/crossdomain.xml'  target='_blank'>/crossdomain.xml</a>
  <li><b>/sql2.../:</b>
  <ul>
  <li><a href='/sql2xml/show tables'  target='_blank'>/sql2xml/...</a>
  <li><a href='/sql2json/show tables'  target='_blank'>/sql2json/...</a>
  </ul>
  <li><a href='/kill/'><b>kill server</b></a>
  """

  response.write '<hr><ul><li><b>/cgi-json/:</b><ul>'
  files = fs.readdirSync "#{path.join dir, 'json'}"
  for cof in files
    response.write "<li><a href='/cgi-json/#{cof}' target='_blank'>/cgi-json/#{cof}</a>"
  
  response.write '</ul><hr><li><b>/cgi-xml/:</b><ul>'
  files = fs.readdirSync "#{path.join dir, 'xml'}"
  for cof in files
    response.write "<li><a href='/cgi-xml/#{cof}' target='_blank'>/cgi-xml/#{cof}</a>"
  response.write '</ul></ul></div>'
  
  response.end ''

.listen 9001

if process.argv.length==2
  console.log "Server started at http://127.0.0.1:9001"
  open "http://127.0.0.1:9001/Starting #{srvname}"
else
  console.log "Server REstarted at http://127.0.0.1:9001"

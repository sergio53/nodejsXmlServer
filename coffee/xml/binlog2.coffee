module.exports = new (require 'events').EventEmitter #!!!!!!!!!!!!!!!!!!!!!!

async = require 'async'
mysql = require 'mysql'
fs= require 'fs'

versionOf = fs.statSync(process.argv[1]).mtime.toISOString()[..9]

request = "pCode=2RH31S101XG01&pStart=200910061523&pStop=201103281305"

if process.argv.length==3
  if process.argv[2]!='' then request = process.argv[2]

map = {}
for q in request.split '&' then v = q.split '=' ; map[v[0]]=v[1]

pCode = map['pCode']
pStart = map['pStart']
pStop = map['pStop']
tStart = pStart.replace /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})/, "$1-$2-$3 $4:$5"
tStop = pStop.replace /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})/, "$1-$2-$3 $4:$5"

sql1 = "select name, nserv from svod_code where code='#{pCode}';"
sql2 = """select tstamp, value, vf, hand, a_ext from dx
where code = '#{pCode}'
and tstamp between '#{pStart}' and '#{pStop}'
order by 1 desc;
"""

connection = mysql.createConnection
  host: 'ec2-54-208-78-75.compute-1.amazonaws.com'
  user: 'userairs'
  password: 'userairs'
  database : 'airs'

finit= ->  
  connection.end ''
  console.log "</ROWSET>"            
  module.exports.emit '</ROWSET>' #!!!!!!!!!!!!!!!!!!!!!!

console.log """<?xml version='1.0' encoding='UTF-8'?>
<ROWSET autor='is10-99' versionOf='#{versionOf}'>
<!-- #{process.argv[1]}
?#{request} -->
<PARAMS pCode='#{map['pCode']}' pStart='#{map['pStart']}' pStop='#{map['pStop']}' />
<interval pStart='#{tStart}' pStop='#{tStop}'/>
<!-- #{sql1}  -->
<!-- #{sql2}  -->
"""
connection.connect

async.parallel [
  (cb)-> connection.query sql1, 
    (err, rows, fields)-> cb err, rows
  (cb)-> connection.query sql2, 
    (err, rows, fields)-> cb err, rows, fields
],
  (error,res)->
    if error
      console.error error
      console.log "<error> <![CDATA[#{error}]]></error>"; finit ''
    else
      rows1 = res[0]
      rows2 = res[1][0]
      fields = res[1][1]

      if rows1.length==0 then  finit ''; return
      console.log """<signal>
        <name><![CDATA[#{rows1[0]['name']}]]></name>
        <nserv><![CDATA[#{rows1[0]['nserv']}]]></nserv>
        </signal>"""

      for row in rows2
        console.log "<ROW>"
        for fild in fields
          if fild.name=='tstamp'
            val = row['tstamp'].replace /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})/, "$1-$2-$3 $4:$5"
          else
            val = row[fild.name]
          console.log "<#{fild.name}><![CDATA[#{val}]]></#{fild.name}>"
        console.log "</ROW>"
      finit ''


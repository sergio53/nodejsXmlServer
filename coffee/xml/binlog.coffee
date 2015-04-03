module.exports = new (require 'events').EventEmitter #!!!!!!!!!!!!!!!!!!!!!!

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
connection.query sql1, (err1, rows1, fields1)->
  if err1
    console.log "<error1> <![CDATA[#{err1}]]></error1>"
    finit ''
  else
    if rows1.length==0 
      finit ''
      return
    connection.query sql2, (err2, rows2, fields2)->        
      if err2
        console.log "<error2> <![CDATA[#{err2}]]></error2>"
        finit ''
      else
        console.log """<signal>
          <name><![CDATA[#{rows1[0]['name']}]]></name>
          <nserv><![CDATA[#{rows1[0]['nserv']}]]></nserv>
          </signal>"""
        for row in rows2
          console.log "<ROW>"
          for fild in fields2
            if fild.name=='tstamp'
              val = row['tstamp'].replace /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})/, "$1-$2-$3 $4:$5"
            else
              val = row[fild.name]
            console.log "<#{fild.name}><![CDATA[#{val}]]></#{fild.name}>"
          console.log "</ROW>"
        finit ''

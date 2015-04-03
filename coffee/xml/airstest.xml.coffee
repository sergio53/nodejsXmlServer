module.exports = new (require 'events').EventEmitter #!!!!!!!!!!!!!!!!!!!!!!

mysql = require 'mysql'
fs= require 'fs'
versionOf = fs.statSync(process.argv[1]).mtime.toISOString()[..9]

sql = 'SELECT * from svod_code where type=\'d\' order by code limit 100;'
if process.argv.length==3
  if process.argv[2]!='' then sql = process.argv[2]
connection = mysql.createConnection
  host: 'ec2-54-208-78-75.compute-1.amazonaws.com'
  user: 'userairs'
  password: 'userairs'
  database : 'airs'

console.log """<?xml version='1.0' encoding='UTF-8'?>
  <ROWSET autor='is10-99' versionOf='#{versionOf}'>
  <!-- #{process.argv[1]}
  ?#{sql}
  -->"""

connection.connect
connection.query sql, (err, rows, fields)->
  connection.end ''
  if err
    console.log "<error> <![CDATA[#{err}]]></error>"
  else
    for row in rows
      console.log "<ROW>"
      for fild in fields
        console.log "<#{fild.name}><![CDATA[#{row[fild.name]}]]></#{fild.name}>"
      console.log "</ROW>"
  console.log "</ROWSET>"
  module.exports.emit '</ROWSET>' #!!!!!!!!!!!!!!!!!!!!!!

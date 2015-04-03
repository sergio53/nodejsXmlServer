module.exports = new (require 'events').EventEmitter #!!!!!!!!!!!!!!!!!!!!!!

mysql = require 'mysql'

sql = 'SELECT * from svod_code where type=\'d\' order by code limit 7;'
if process.argv.length==3
  if process.argv[2]!='' then sql = process.argv[2]
connection = mysql.createConnection
  host: 'ec2-54-208-78-75.compute-1.amazonaws.com'
  user: 'userairs'
  password: 'userairs'
  database : 'airs'

connection.connect
connection.query sql,
  (err, rows)->
    if err
      console.log """{"error": "#{err}"}"""
    else
      console.log JSON.stringify rows
    module.exports.emit '</ROWSET>' #!!!!!!!!!!!!!!!!!!!!!!

connection.end()

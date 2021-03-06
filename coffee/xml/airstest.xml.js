// Generated by CoffeeScript 1.9.1
(function() {
  var connection, fs, mysql, sql, versionOf;

  module.exports = new (require('events')).EventEmitter;

  mysql = require('mysql');

  fs = require('fs');

  versionOf = fs.statSync(process.argv[1]).mtime.toISOString().slice(0, 10);

  sql = 'SELECT * from svod_code where type=\'d\' order by code limit 100;';

  if (process.argv.length === 3) {
    if (process.argv[2] !== '') {
      sql = process.argv[2];
    }
  }

  connection = mysql.createConnection({
    host: 'ec2-54-208-78-75.compute-1.amazonaws.com',
    user: 'userairs',
    password: 'userairs',
    database: 'airs'
  });

  console.log("<?xml version='1.0' encoding='UTF-8'?>\n<ROWSET autor='is10-99' versionOf='" + versionOf + "'>\n<!-- " + process.argv[1] + "\n?" + sql + "\n-->");

  connection.connect;

  connection.query(sql, function(err, rows, fields) {
    var fild, i, j, len, len1, row;
    connection.end('');
    if (err) {
      console.log("<error> <![CDATA[" + err + "]]></error>");
    } else {
      for (i = 0, len = rows.length; i < len; i++) {
        row = rows[i];
        console.log("<ROW>");
        for (j = 0, len1 = fields.length; j < len1; j++) {
          fild = fields[j];
          console.log("<" + fild.name + "><![CDATA[" + row[fild.name] + "]]></" + fild.name + ">");
        }
        console.log("</ROW>");
      }
    }
    console.log("</ROWSET>");
    return module.exports.emit('</ROWSET>');
  });

}).call(this);

var mysql = require('mysql');
//
debugger;
var sql = 'SELECT * from svod_code where type=\'d\' order by code;';
//var sql = 'SELECT 1 ONE;';
if(process.argv.length===3) if(process.argv[2]!=='') sql = process.argv[2];
var connection = mysql.createConnection({
  host: 'ec2-54-208-78-75.compute-1.amazonaws.com',
  user: 'userairs',
  password: 'userairs',
  database : 'airs'
});
connection.connect();
connection.query(sql,
  function(err, rows, fields) {
    connection.end();
    if (err) throw err;
    console.log(JSON.stringify(rows));
  }
);

/**/
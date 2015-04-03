var connect = require("connect");
connect()
    .use(connect.favicon())
    .use(connect.cookieParser())
    .use(connect.session({ secret: 'keyboard cat', cookie: { maxAge: 60000 }}))
    .use(function(req, res, next){
      var sess = req.session;
      if (sess.views) {
        res.setHeader('Content-Type', 'text/html');
        res.write('<p>views: ' + sess.views + '</p>');
        res.write('<p>expires in: ' + (sess.cookie.maxAge / 1000) + 's</p>');
        res.end();
        sess.views++;
      } else {
        sess.views = 1;
        res.end('welcome to the session demo. refresh!');
      }
    }
).listen(3000);

console.log("Server running at http://127.0.0.1:3000/");
open('http://127.0.0.1:3000/Hello World');

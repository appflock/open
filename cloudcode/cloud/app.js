
// These two lines are required to initialize Express in Cloud Code.
express = require('express');
app = express();


var WebUtil = require('cloud/webutil.js');

// Global app configuration section
app.set('views', 'cloud/views');  // Specify the folder to find templates
app.set('view engine', 'ejs');    // Set the template engine
app.use(express.bodyParser());    // Middleware for reading request body

// Render a post with specific ID
app.get('/post/:id', function(req, res) {
	WebUtil.getPost({
		postId: req.params.id,
		success: function(post, comments) {
			res.render('post', {
				post: post,
				comments: comments
			});
		},
		error: function(error) {
			res.render('post', {
				error: error
			});
		}
  });
});

// // Example reading from the request query string of an HTTP get request.
// app.get('/test', function(req, res) {
//   // GET http://example.parseapp.com/test?message=hello
//   res.send(req.query.message);
// });

// // Example reading from the request body of an HTTP post request.
// app.post('/test', function(req, res) {
//   // POST http://example.parseapp.com/test (with request body "message=hello")
//   res.send(req.body.message);
// });

// Attach the Express app to Cloud Code.
app.listen();

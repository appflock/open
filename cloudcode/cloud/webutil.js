exports.getPost= function(params) {
	var Post = Parse.Object.extend("Post");
	var query = new Parse.Query(Post);
  query.equalTo("objectId", params.postId);
	query.equalTo("type", "text");
	query.include("company");
	query.first({
		success: function(post) {
			console.log("Found post " + params.postId + " - " + post.get("content"));
			var commentQuery = new Parse.Query(Post);
      commentQuery.equalTo("parent", post);
			commentQuery.equalTo("type", "comment");
			commentQuery.include("company");
      commentQuery.ascending("createdAt");

			commentQuery.find({
				success: function(results) {
					var comments = [];
					if (results) {
						for (var i = 0; i < results.length; i++) {
							comments.push({
								"company": results[i].get("company").get("name"),	
								"content": results[i].get("content"),
								"createdAt": results[i].get("createdAt")
							});
						}
					}
					params.success(
						{
							"company": post.get("company").get("name"),	
							"content": post.get("content"),
							"createdAt": post.get("createdAt")
						},
						comments);
				},
				error: function(error) {
					params.error(error);
				}
			});
		},
		error: function(error) {
			params.error(error);
		}
	});
}


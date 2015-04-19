var profile = require('cloud/profile.js');
exports.getById = function(id, func) {
  query = new Parse.Query("Post");
  return query.get(id, {
    success: function(post) {
      return func(post);

    },
    error: function(error) {
      console.error("Fail to get post " + id + " code= " + error.code + "  message=" + error.message);
      return null;
    }
  })
}

/**
 push trigger
**/
Parse.Cloud.afterSave("Post", function(request) {
  Parse.Cloud.useMasterKey();
  query = new Parse.Query("Post");
  query.include("company");

  // Emit an event that updating the Event
  if (request.object.get("type") == "text") {
    // write to inbox
    var Event = Parse.Object.extend("Event");
    // get the current calling user - note a post can be updated triggered by other eventß
    if (request.user) {
      profile.getProfile({
        user: request.user,
        success: function(profile) {
          var event = new Event();
          event.set("userHash", profile.get("userHash")); // translate to 
          event.set("target", request.object);
          event.set("eventType", "text");
          event.set("objectType", "Post");
          event.set("processTime", null);
          event.save(null, {
            success: function(event) {
              // Execute any logic that should take place after the object is saved.
              console.log('New object created with objectId: ' + event.id);
            },
            error: function(event, error) {
              // Execute any logic that should take place if the save fails.
              // error is a Parse.Error with an error code and message.
              alert('Failed to create new object, with error code: ' + error.message);
            }
          });
          //response.success();
        },
        error: function(error) {
          console.error("Got an error " + error.code + " : " + error.message);

        }
      });
    }

  } else if (request.object.get("type") == "comment") {
    console.log("On Comment save updating:" + request.object.get("parent").id)

    query.get(request.object.get("parent").id, {
      success: function(post) {

        // write to inbox
        var Event = Parse.Object.extend("Event");
        // Create a new instance of that class.
        var event = new Event();
        event.set("userHash", request.object.get("userHash"));
        event.set("target", request.object);
        event.set("eventType", "comment");
        event.set("objectType", "Post");
        event.set("processTime", null);
        event.save(null, {
          success: function(event) {
            post.increment("commentCount");
            post.save().then(function(result){
              var eventPost = new Event();
              eventPost.set("userHash", request.object.get("userHash"));
              eventPost.set("target", post);
              eventPost.set("eventType", "text");
              eventPost.set("objectType", "Post");
              eventPost.set("processTime", null);
              eventPost.save().then(function(result){console.log('New eventPost created with objectId: ' + result.id);});   
            });
            console.log('New event created with objectId: ' + event.id);
          },
          error: function(event, error) {
            // Execute any logic that should take place if the save fails.
            // error is a Parse.Error with an error code and message.
            alert('Failed to create new object, with error code: ' + error.message);
          }
        });
      },
      error: function(error) {
        console.error("Got an error " + error.code + " : " + error.message);
      }
    });
  } else {
    console.log("Unhandled Post type " + request.object.get("type") + " for object " + request.object.id);
  }
});

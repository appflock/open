var _ = require('underscore');


var run_event_processor = function(request, status) {
  // Query for all unprocessed events
  var query = new Parse.Query("Event");
  query.equalTo("processTime", null)
    //.limit(10) FIXME: limit does' work, is it a lib bug?
    .include("target")
    .include("target.parent");
  return query.each(function(event) {
    // Update to plan value passed in
    event.set("processTime", new Date());
    if (event.get("objectType") == "Post" && event.get("eventType") == "comment") { // it is an event trigged by adding comment
      var sourceComment = event.get("target");
      console.log("Job running in Post + comment Type for event " + event.id + " linking to post " + sourceComment.id);
      var dropInbox4OtherComments = function() {
        console.log("Start to find all comments with the same parent of " + sourceComment.id);
        var allCommentQuery = new Parse.Query("Post");
        var Post = Parse.Object.extend("Post");
        var parentPost = new Post();
        parentPost.id = sourceComment.get("parent").id;
        allCommentQuery.limit(100);
        allCommentQuery.equalTo("parent", parentPost);
        allCommentQuery.notEqualTo("userHash", sourceComment.get("userHash"));
        return allCommentQuery.find({
          success: function(otherComments) {
            var objectsToSave = [];
            for (var i = 0; i < otherComments.length; i++) {
              console.log("Creating inbox for comment: " + otherComments[i].id);
              var Inbox = Parse.Object.extend("Inbox");
              // Create a new instance of that class.
              var inbox = new Inbox();
              inbox.set("sourceEvent", event);
              inbox.set("inboxMsg", "The post you commented has been updated.");
              inbox.set("eventType", "comment");
              inbox.set("owner", otherComments[i].get("userHash"));
              inbox.set("objectRef", otherComments[i]);
              inbox.set("objectType", "Post");
              inbox.set("status", "unprocessed");
              objectsToSave.push(inbox.save());
            }
            return objectsToSave;
          },
          error: function(error) {
            console.error("Got an error from fetching all comments " + error.code + " : " + error.message);
            return [];
          }
        })
      };

      event.set("status", "OK");
      // doing all three promises together

      var listOfPromises = event.save().then(
        function(result) {
          console.log("pre dropInbox4OtherComments");
          return dropInbox4OtherComments();
        },
        function(error) {
          console.error("Fail to save postPromise " + error.message);
        }
      );

      return Parse.Promise.when(listOfPromises);
    } else if (event.get("objectType") == "Post" && event.get("eventType") == "text") { // it is an event trigged by updating post(e.g. increase like)     
      var post = event.get("target");
      console.log("Job running in Post + text Type for event " + event.id + " linking to post " + post.id);

      var dropInbox4PostOwner = function() {
        console.log("creating inbox object for post " + post.id);
        var Inbox = Parse.Object.extend("Inbox");
        // Create a new instance of that class.
        var inbox = new Inbox();
        inbox.set("sourceEvent", event);
        inbox.set("inboxMsg", "Your post has been commented");
        inbox.set("eventType", "comment");
        inbox.set("objectRef", post);
        inbox.set("owner", post.get("userHash"));
        inbox.set("objectType", "Post");
        inbox.set("status", "unprocessed");
        return inbox.save();
      };
      event.set("status", "OK");
      return event.save().then(
        function(result) {
          console.log("pre dropInbox4PostOwner");
          if (post.get("userHash") != event.get("userHash")) {
            console.log("event triggered by the diff owner " + event.id + " add event to inbox for user " + post.get("userHash"));
            return dropInbox4PostOwner();
          } else {
            console.log("event triggered by the same owner " + event.id);
            return Parse.Promise.as();
          }
        },
        function(error) {
          console.error("Fail to save event " + error.message);
        });

    } else { // rest of the case
      event.set("status", "UnknownType")
      console.error("Unknown event type ObjectType=" + event.get("objectType") + " eventType=" + event.get("eventType"));

      return event.save();
    }
  }).then(function() {
    // Set the job's success status
    status.success = "Event Rolling table completed";
  }, function(error) {
    // Set the job's error status
    status.error = "Hmm! Dead! " + error.message;
  });
}

var run_inbox_push_processor = function(request, status) {
  // Query for all unprocessed events
  var query = new Parse.Query("Inbox");
  var owner2ListOfObjectRef = {};
  var promises = [];
  query.equalTo("pushedOn", null);

  query.limit(10);
  return query.find({
    success: function(inboxes) {
      console.log("Dealing with inbox items item count " + inboxes.length);
      for (var i = 0; i < inboxes.length; i++) {
        var inbox = inboxes[i];
        console.log(owner2ListOfObjectRef);
        //console.log(inbox)
        if (owner2ListOfObjectRef[inbox.get("owner")]) {
          owner2ListOfObjectRef[inbox.get("owner")].push(inbox.get("objectRef").id);
          // console.log("if " + inbox.get("owner") + " " + owner2ListOfObjectRef);
        } else {
          owner2ListOfObjectRef[inbox.get("owner")] = [inbox.get("objectRef").id];
          // console.log("else " + inbox.get("owner") + " " + owner2ListOfObjectRef);
        }
        inbox.set("pushedOn", new Date());
        promises.push(inbox.save());
      }
      var doPush = function() {
        console.log("Now start pushing to:");
        console.log(owner2ListOfObjectRef);
        var pushes = []
        Object.keys(owner2ListOfObjectRef).forEach(function(key) {
          console.log(owner2ListOfObjectRef[key]);
          var pushQuery = new Parse.Query("Installation").containedIn("userHash", [key]);
          var payload = _.uniq(owner2ListOfObjectRef[key])
          var p = Parse.Push.send({
            where: pushQuery,
            data: {
              alert: payload.length + " udpates. Check it out!" ,
              payload: payload
            }
          }, {
            success: function() {
              console.log("Push was successful");
            },
            error: function(error) {
              console.error(error);
            }
          });
          pushes.push(p);
        });
        return Parse.Promise.when(pushes);
      };
      promises.push(doPush());
      return Parse.Promise.when(promises);

    },
    error: function(error) {
      console.error("Got an error from fetching selected inbox " + error.code + " : " + error.message);
      return [];
    }
  }).then(function() {

    status.success = "Inbox Rolling table completed " + owner2ListOfObjectRef;
  }, function(error) {
    console.error(error);
    // Set the job's error status
    status.error = "Hmm! Dead! " + error.message;
  });
}



Parse.Cloud.job("Process_event_then_push", function(request, status) {
  console.log("== Job running Process_event_then_push ==");
  Parse.Cloud.useMasterKey();
  var event_processor_status = [];
  var inbox_push_processor_status = [];

  run_event_processor(request, event_processor_status)
    .then(function(x){
      return run_inbox_push_processor(request, inbox_push_processor_status); 
  }).then(function(x){
    console.log("Done Process_event_then_push");
    console.log(event_processor_status);
    console.log(inbox_push_processor_status);
    if (event_processor_status.error)
      status.error("event_processor_status.error: " + event_processor_status.error);
    else if (inbox_push_processor_status.error)
      status.error("inbox_push_processor.error: " + inbox_push_processor_status.error);
    else
      status.success("Process_event_then_push done");
  });
});

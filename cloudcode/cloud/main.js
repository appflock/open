// Express
require('cloud/app.js');

require('cloud/post.js')
require('cloud/job.js') // for job lib
require('cloud/inst.js')

var profile = require('cloud/profile.js');

/**
 * Create new anonymous profile for the logged in user. A verification
 * will be sent to provided email address.
 */
Parse.Cloud.define("createNewProfile", function(request, response) {
  if (!request.user) {
    response.error("No logged in user");
    return;
  }
  
  if (!request.params.emailAddress) {
    response.error("Parameter is missing");
    return;
  }
  
  profile.createNewProfile({
    user: request.user,
    emailAddress: request.params.emailAddress,
    success: response.success,
    error: response.error
  });
});

/**
 * Confirm the anonymous profile with verification code
 */
Parse.Cloud.define("confirmProfile", function(request, response) {
  if (!request.user) {
    response.error("No logged in user");
    return;
  }
  
  if (!request.params.verificationCode) {
    response.error("Parameter is missing");
    return;
  }
  
  profile.confirmProfile({
    user: request.user,
    verificationCode: request.params.verificationCode,
    success: response.success,
    error: response.error
  });
});


/**
 * afterSave for Activity
 */
Parse.Cloud.afterSave("Activity", function(request) {
  Parse.Cloud.useMasterKey();

  console.log("request.user = " + request.user);
  //move activity to event
  if (request.user) {
    profile.getProfile({
      user: request.user,
      success: function(profile) {
        var Event = Parse.Object.extend("Event");
        var event = new Event();
        event.set("userHash", profile.get("userHash")); // translate to 
        event.set("activity", request.object);
        event.set("target", request.object.get("target"));
        event.set("eventType", request.object.get("type"));
        event.set("objectType", "Activity");
        event.set("processTime", null);
        event.save(null, {
          success: function(event) {
            console.log('Activity.afterSave New object created with objectId: ' + event.id);
          },
          error: function(event, error) {
            alert('Failed to create new object, with error code: ' + error.message);
          }
        });
      },
      error: function(error) {
        console.error("Got an error " + error.code + " : " + error.message);
      }
    });
  }
})

/**
 * beforeSave for Post
 */
Parse.Cloud.beforeSave("Post", function(request, response) {
  console.log("Before Save Post");
  if (!request.user && request.object.get("userHash")) {
    console.log("This is from cloud code, userHash has set");
    response.success();
    return;
  }

  if (!request.user) {
    response.error("No logged in user");
    return;
  }

  profile.getProfile({
    user: request.user,
    success: function(profile) {
      request.object.set("userHash", profile.get("userHash"));
      request.object.set("company", profile.get("company"));
      response.success();
    },
    error: function(error) {
      response.error(error);
    }
  });
});



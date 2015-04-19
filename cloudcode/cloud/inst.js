
var profile = require('cloud/profile.js');

Parse.Cloud.beforeSave(Parse.Installation, function(request, response) {
  console.log("Before Save installation again");
  Parse.Cloud.useMasterKey();
  profile.getProfile({
    user: request.user,
    success: function(profile) {
      console.log("Updating installation");
      request.object.addUnique("userHash", profile.get("userHash"));
      request.object.addUnique("company", profile.get("company").id);
      response.success();
    },
    error: function(error) {
      console.error("fail to get profile for installation");
      response.error(error);
    }
  });
});

/**
 * REGISTER A NEW ACCOUNT WITH MANDRILL AND PUT YOUR APP KEY HERE
 */
var Mandrill = require('mandrill');

var MandrillApiKey = '__YOUR_MANDRILL_API_KEY__';

Mandrill.initialize(MandrillApiKey);

var crypto = require('crypto');

function generateRandomString(length) {
  var chars = "0123456789";
  var randomstring = '';
  for (var i = 0; i < length; i++) {
      var rnum = Math.floor(Math.random() * chars.length);
      randomstring += chars.substring(rnum,rnum + 1);
  }
  return randomstring;
}

function generateUserHash(user) {
  var hash = crypto.createHash('sha256');
  hash.update(user.id);
  hash.update(Date.now().toString());
  return hash.digest('base64');
}

function sendEmail(subject, from, to, text, success, error) {
  Mandrill.sendEmail({
    message: {
      subject: subject,
      from_email: from,
      from_name: from,
      to: [
        {
          email: to,
          name: to
        }
      ],
      
      text: text
    },
    async: true
  }, {
    success: function(httpResponse) {
      console.log("Http response from Mandrill.sendEmail");
      console.log(httpResponse);
      success();
    },
    error: function(httpResponse) {
      console.error("Http response from Mandrill.sendEmail");
      console.error(httpResponse);
      error();
    }
  });
}

function getCompanyByEmailDomain(params) {
  var Company = Parse.Object.extend("Company");
  var query = new Parse.Query(Company);
  query.equalTo("emailDomain", params.emailDomain);
  query.first({
    success: function(company) {
      if (company) {
        console.log("Found company with email domain " + params.emailDomain);
        console.log(company);
        params.success(company);
      } else {
        console.log("User put in a new email domain, " + params.emailDomain +
                    ", adding to our company list");
        var Company = Parse.Object.extend("Company");
        var newCompany = new Company();
        newCompany.set("name", params.emailDomain);
        newCompany.set("emailDomain", params.emailDomain);
        newCompany.save(null, {
          success: function(company) {
            params.success(company);
          },
          error: function(company, error) {
            params.error(error);
          }
        });
      }
    },
    error: function(error) {
      params.error(error);
    }
  })
}

function refreshUser(params, func) {
  params.user.fetch({
    success: function(user) {
      console.log("User refreshed");
      params.user = user;
      func(params);
    },
    error: function(user, error) {
      func(params);
    }
  });
}

function createNewProfileInternal(params) {
  var emailDomain = params.emailAddress.slice(params.emailAddress.search("@")).toLowerCase();
  getCompanyByEmailDomain({
    emailDomain: emailDomain,
    success: function(company) {
      if (!company) {
        params.error("Thanks for your support. We will expand our service to " + emailDomain + " soon");
        return;
      }
      var verificationCode = generateRandomString(4);
      var Profile = Parse.Object.extend("Profile");
      var profile = new Profile();
      //profile.set("emailAddress", params.emailAddress);
      profile.set("company", company);
      profile.set("userHash", generateUserHash(params.user));
      profile.set("verificationCode", verificationCode);
      profile.set("verified", 0);
      profile.setACL(new Parse.ACL(params.user));
      
      params.user.set("profile", profile);
      params.user.save(null, {
        success: function(user) {
          sendEmail(
            "Welcome to Open anonymous app",
            "no-reply@example.com",
            params.emailAddress,
            verificationCode,
            function() {
              params.success();
            },
            function() {
              params.error("verification email failed to send");
            });
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

function confirmProfileInternal(params) {
  var profile = params.user.get("profile");
  if (!profile) {
    params.error("Try again");
    return;
  }
  
  profile.fetch({
    success: function(profile) {
      var verificationCode = profile.get("verificationCode");
      if (verificationCode && verificationCode == params.verificationCode) {
        profile.set("verified", 1);
        profile.save(null, {
          success: function(profile) {
            params.success();
          },
          error: function(profile, error) {
            params.error("Try again");
          }
        });
      } else {
        params.error("Verification code doesn't match");
      }
    },
    error: function(profile, error) {
      params.error(error);
    }
  });
}

function getProfileInternal(params) {
  var profile = params.user.get("profile");
  if (!profile) {
    params.error("No profile found for user");
    return;
  }
  
  profile.fetch({
    success: function(profile) {
      params.success(profile);
    },
    error: function(profile, error) {
      params.error(error);
    }
  });
}

exports.getProfile = function(params) {
  refreshUser(params, getProfileInternal);  
}

exports.createNewProfile = function(params) {
  refreshUser(params, createNewProfileInternal);
}

exports.confirmProfile = function(params) {
  refreshUser(params, confirmProfileInternal);
}


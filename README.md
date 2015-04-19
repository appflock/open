# Open - Anonymous app built on top of Parse #

This project consists on two main parts, iOS app and Parse backend. You can find all the code under the ios/ and cloudcode/ directory.

## Dependencies ##
- Parse
- Mandrill

## Configuration instructions ##

Before you deploy your app, you need to sign up two free services

### Parse (www.parse.com) ###

You need to create a new app in Parse by following the instructions on the website (There should be a create new app button on the Dashboard). You will need to install command line for cloud code before deploying your shiny new app (https://www.parse.com/docs/cloud_code_guide)

### Mandrill (www.mandrill.com) ###

This is a free service to send email to your users. Parse can call it directly with the API to send verification email. Create a new API key by going to Settings -> New API Key).

### Setup iOS app ###
- Open ios/Reveal/AppDelegate.m, and copy your Parse application id and client key (Go to Dashboard -> Your app -> Settings -> Keys)

### Setup Cloud Code ###
- Open cloudcode/config/global.json, and copy your Parse application id and master key (Go to Dashboard -> Your app ->Settings -> Keys). Our app is named as "Open", you may need to change to your app name.
- Open cloudcode/cloud/profile.js and copy your Mandrill API key (Settings -> API Keys).

## Deployment instructions ##

- Go to cloudcode/ directory and deploy it to Parse (Assuming you have cloud code command line installed)
```
$ parse deploy
```

### Contribution guidelines ###

* Writing tests
* Code review
* Other guidelines

### Who do I talk to? ###

* Repo owner or admin
* Other community or team contact


### What is this repository for? ###

* Quick summary
* Version
* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)

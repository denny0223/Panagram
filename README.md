# Panagram

This is a project developed by Johan Henkens and Kyle Jorgensen of UC Santa Barbara for CMPSC 263, Spirng 2014.

Panagram is a photo-sharing style application, specifically tailored for panoramic photos. [Panagram](http://panagram.parseapp.com/#) is fully powered by [Parse](https://parse.com), and runs on iOS, Android, and the web. It is integrated with Facebook for user authentication. 

Here is the [Anypic tutorial](https://parse.com/tutorials/anypic) from which this project is derived. We have built upon the original iOS Anypic code, and have created the Android and web versions mostly from scratch. 

## Overview
* [iOS Setup](#ios-setup)
* [Android Setup](#android-setup)
* [Web Setup](#web-setup)
* [Cloud Code](#cloud-code)
* [Background Info](#background-information)

## iOS Setup

Panagram requires Xcode 5 and iOS 7. The [tutorial](https://parse.com/tutorials/anypic) provides additional setup instructions.

#### Setting up your Xcode project

1. Open the Xcode project at `Panagram-iOS/Panagram.xcodeproj`.

2. Create your Panagram App on [Parse](https://parse.com/apps).

3. Copy your new app's application id and client key into `AppDelegate.m`:

```objective-c
[Parse setApplicationId:@"APPLICATION_ID" clientKey:@"CLIENT_KEY];"
```

#### Configuring Panagram's Facebook integration

1. Set up a Facebook app at http://developers.facebook.com/apps

2. Set up a URL scheme for fbFACEBOOK_APP_ID, where FACEBOOK_APP_ID is your Facebook app's id. 

3. Add your Facebook app id to `Info.plist` in the `FacebookAppID` key.

## Android Setup

Make sure you have the Android SDK installed on your system. The version of the Eclipse IDE with ADT (Android Developer Tools) built-in can be found [here](http://developer.android.com/sdk/index.html). Panagram is designed for Android version 4.0 and above. 

#### How to Run

1. Clone the repository and open the project in Eclipse 
	1. (For Android Studio set up, you're on your own) 
2. Create your Panagram App on [Parse](https://parse.com/apps).
3. Add your Parse application ID and client key in `AnypicApplication.java`
```java

Parse.initialize(this, "<APP_ID>", "<CLIENT_KEY>");
```
**4. Set up the Facebook SDK**

* follow the [Facebook User guide](https://www.parse.com/docs/android_guide#fbusers) in Parse's Android documentation. 
* You will have to create a Facebook application for your app, and then you will have to put the Facebook Application ID into `AnypicApplication.java`

```java
ParseFacebookUtils.initialize("YOUR FACEBOOK APP ID");
```

* Make sure that the `facebooksdk.jar` file is [added as an Android Dependency](http://stackoverflow.com/questions/20355971/how-do-i-add-a-new-library-to-android-dependencies-using-eclipse-adt) to your project.

5.Build the project and run

## Web Setup 

The main Panagram site is at Panagram-cloud/public/index.html. The site will show the last eight photos uploaded to your Panagram app by default. You can click any of these photos to display a bigger version.


#### Parse JavaScript SDK

http://panagram.parseapp.com/ is built on top of the [Parse JavaScript SDK](https://parse.com/docs/js_guide). The main JavaScript file is at `Panagram-cloud/public/js/panagram.js`.

To get started, copy your app's id and JavaScript key into `panagram.js`:

```javascript
Parse.initialize("APPLICATION_ID", "JAVASCRIPT_KEY");
```

You'll notice that there is only one index.html, however Panagram's website displays different content for the homepage and for a single photo's landing page. This is accomplished using [Backbone.js](http://backbonejs.org/)'s `Backbone.Router`. The following lines set up the two routes:

```javascript
routes: {
  "pic/:object_id": "getPic",
  "*actions": "defaultRoute"
}
``` 

Whenever `/#pic/<object_id>` is visited, the Router will call the `getPic` function and pass along the object id for the photo that should be presented. The `getPic` function loads the photo landing page into the DOM, then obtains the photo from Parse using `Parse.Query`.

Any other URL will call the defaultRoute function, which should load the homepage into the DOM.

#### CSS

Anypic uses [Sass](http://sass-lang.com/) and [Compass](http://compass-style.org/) to generate its CSS. You will find the main SCSS file at `sass/screen.scss`. To get started, run `compass watch` from the Panagram-cloud/public folder.

Any changes made to the `.scss` files in `sass/` will be picked up by Compass and used to generate the final CSS files at `stylesheets/`.

Panagram uses media queries to present different layouts on iPad, iOS and various desktop resolutions. These media queries will apply different CSS properties, as defined by `_320.scss`, `_480.scss`, `_768.scss`, `_1024.scss`, and `_1024.scss` depending on the device's horizontal resolution. You can modify these in `sass/screen.scss`. The following media query applies the CSS rules laid out in `_320.scss` when your website is visited from an iPhone, for example:

```sass
@media only screen and (max-width : 320px) { @import "320" }
```

## Cloud Code

Add your Parse app id and master key to `Panagram-cloud/config/global.json`, then type `parse deploy` from the command line at `Panagram-cloud`. See the [Cloud Code Guide](https://parse.com/docs/cloud_code_guide#clt) for more information about the Parse CLI.

## Background Information

A video describing our project can be found [here](https://www.youtube.com/watch?v=xLdTZYzK_j4)

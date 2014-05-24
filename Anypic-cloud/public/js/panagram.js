$(function () {

    Parse.$ = jQuery;

    Parse.initialize("cLXA3EhzyvWXitzfo8VNlqFEetDG9vKQgt87P85F", "khkNsvQleaXtJG59RCR1UPLryO66HenEP8xaBfaN");

    window.fbAsyncInit = function () {
        Parse.FacebookUtils.init({
            appId: '1415285015407362', // Facebook App ID
            cookie: true, // enable cookies to allow Parse to access the session
            xfbml: true,
            version: 'v1.0'
            // parse XFBML
        });
    };


    (function (d, s, id) {
        var js, fjs = d.getElementsByTagName(s)[0];
        if (d.getElementById(id)) {
            return;
        }
        js = d.createElement(s);
        js.id = id;
        js.src = "//connect.facebook.net/en_US/all.js";
        fjs.parentNode.insertBefore(js, fjs);
    }(document, 'script', 'facebook-jssdk'));



    // Copied from AnyPic
    var Photo = Parse.Object.extend("Photo", {
        photoURL: function() {
            return "#pic/" + this.id;
        },
        photoImageURL: function() {
            return this.get("image").url().replace(/http:\/\//,"https://s3.amazonaws.com/");
        },
        createdTime: function() {
            return this.createdAt;
        },

        photoId: function() {
            return this.id;
        },

        avatarImageURL: function() {
            if (this.get("user").get("profilePictureSmall")) {
                return this.get("user").get("profilePictureSmall").url().replace(/http:\/\//,"https://s3.amazonaws.com/");
            }

            return "";
        },
        displayName: function() {
            return this.get("user").get("displayName");
        }

    });

    var PhotoList = Parse.Collection.extend({
        model: Photo
    });

    // Photo View
    var PhotoView = Parse.View.extend({
        template: _.template($("#photo-template").html()),
        render: function() {
            this.$el.html(this.template({
                "photo_id": this.model.photoId(),
                "photo_url": this.model.photoURL(),
                "photo_image_url": this.model.photoImageURL(),
                "avatar_image_url": this.model.avatarImageURL(),
                "display_name": this.model.displayName(),
                "created_at": this.model.createdTime()
            }));
            var self = this;
            _.delay(function(){self.$el.find("img").unveil(200, function(){$(this).removeClass("unloaded-image")});},250);
            return this;
        }
    });

    // Single Photo View, used to display the big photo in the landing page
    var SinglePhotoView = Parse.View.extend({

        template: _.template($("#big-photo-template").html()),

        initialize: function() {
            this.$el.html(this.template({
                "photo_id": this.model.photoId(),
                "photo_url": this.model.photoURL(),
                "photo_image_url": this.model.photoImageURL(),
                "avatar_image_url": this.model.avatarImageURL(),
                "display_name": this.model.displayName(),
                "created_at": this.model.createdTime()
            }));

            return this;
        },
        render: function(){
            return this;
        }
    });

    var LogInHeader = Parse.View.extend({

        el: ".user-signin-navbar",

        template: _.template($("#login-navbar-template").html()),

        events: {
            "click #facebook-sign-in": "logIn"
        },

        initialize: function () {
            _.bindAll(this, "logIn");
        },

        redirectToMainView: function() {
            this.undelegateEvents();
            App.showHomePage();
        },

        setUpNewUser: function() {
            var self = this;
            FB.api(
                "/me",
                function (response) {
                    if (response && !response.error) {
                        var name = response.name;
                        if (name && name.length > 0){
                            Parse.User.current().set("displayName", name);
                        }
                        var facebookId = response.id;
                        if (facebookId && facebookId.length > 0){
                            Parse.User.current().set("facebookId", facebookId);
                        }
                        Parse.User.current().save();
                    }
                    self.redirectToMainView();
                }
            );
        },

        logIn: function (e) {
            var self = this;
            Parse.FacebookUtils.logIn("user_about_me", {
                success: function (user) {
                    if (!user.existed()) {
                        self.setUpNewUser();
                    } else {
                        self.redirectToMainView();
                    }
                },
                error: function (user, error) {
                    alert("User cancelled the Facebook login or did not fully authorize.");
                }
            });
            return false;
        },


        render: function () {
            this.$el.html(this.template);
            this.delegateEvents();
            return this;
        }
    });

    var LogOutHeader = Parse.View.extend({

        el: ".user-signin-navbar",

        events: {
            "click .log-out": "logOut"
        },

        template: _.template($("#logout-navbar-template").html()),

        initialize: function () {
            _.bindAll(this, "logOut");
        },
        // Logs out the user and shows the login view
        logOut: function(e) {
            Parse.User.logOut();
            window.location.reload();
        },

        render: function () {
            this.$el.html(this.template);
            this.delegateEvents();
            return this;
        }
    });

    var WelcomeView = Parse.View.extend({
        template: _.template($("#welcome-template").html()),

        initialize: function(){
            this.$el.html(this.template);
        },

        render: function(){
            return this;
        }

    });

    var TimelineView = Parse.View.extend({

        // Delegated events for creating new items, and clearing completed ones.

        template: _.template($("#timeline-template").html()),

        initialize: function() {
            var self = this;

            _.bindAll(this, 'addOne', 'addAll');

            this.$el.html(this.template);

            this.photos = new PhotoList();
            this.photos.bind('add', this.addOne);
            this.photos.bind('reset', this.addAll);

        },

        loaded: 0,
        previousCount: 0,
        photosPerPage: 4,

        queryPage: function(page){

            var Activity = Parse.Object.extend("Activity");
            var followingActivitiesQuery = new Parse.Query(Activity);
            followingActivitiesQuery.equalTo("type", "follow");
            followingActivitiesQuery.equalTo("fromUser", Parse.User.current());
            followingActivitiesQuery.limit(1000);

            var photosFromFollowedUsersQuery = new Parse.Query(Photo);
            photosFromFollowedUsersQuery.matchesKeyInQuery("user","toUser",followingActivitiesQuery);
            photosFromFollowedUsersQuery.exists("image");

            var photosFromCurrentUserQuery = new Parse.Query(Photo);
            photosFromCurrentUserQuery.equalTo("user", Parse.User.current());
            photosFromCurrentUserQuery.exists("image");

            // Setup the query for the collection to look for todos from the current user
            this.photos.query = new Parse.Query.or(photosFromCurrentUserQuery,photosFromFollowedUsersQuery);
            this.photos.query.include("user");
            var self = this;
            this.photos.query.count({success: function(count){
                self.previousCount = count;
                console.log("Panagram count:" + self.previousCount)
            }});

            this.photos.query.limit(this.photosPerPage);
            this.photos.query.skip(page*this.photosPerPage);
            this.photos.query.descending("createdAt");

            this.photos.query.count({success: function(count){
                self.loaded += count;
            }});

            this.photos.fetch();
        },



        // Re-rendering the App just means refreshing the statistics -- the rest
        // of the app doesn't change.
        render: function() {
            this.queryPage(0);

            this.$("#photo-list").fadeIn();
            this.delegateEvents();
            return this;
        },

//        // Add a single todo item to the list by creating a view for it, and
//        // appending its element to the `<ul>`.
        addOne: function(photo) {
            // Prevent duplicates
            var photoIdTag = "#"+photo.photoId();
            var existingPhoto = $(photoIdTag)[0];
            if (! existingPhoto ) {
                var view = new PhotoView({model: photo});
                var rendered = view.render();
                this.$("#photo-list").append(rendered.el);
            }
        },

        // Add all items in the Todos collection at once.
        addAll: function(collection, filter) {
            this.$("#photo-list").html("");
            this.photos.each(this.addOne);
        }


    });



    // The main view for the app
    var AppView = Parse.View.extend({
        // Instead of generating a new element, bind to the existing skeleton of
        // the App already present in the HTML.
        el: $(".content"),

        initialize: function () {
            _.bindAll(this, 'showHomePage', 'showPhotoPage', 'render');

            this.timelineView = new TimelineView();
            this.loginHeader = new LogInHeader();
            this.logoutHeader = new LogOutHeader();
            this.welcomeView = new WelcomeView();
            this.render();
        },

        render: function () {
            return this;
        },

        updateHeader: function() {
            if (Parse.User.current()) {
                this.logoutHeader.render();
            } else {
                this.loginHeader.render();
            }
        },

        showHomePage: function() {
            this.updateHeader();
            if (Parse.User.current()) {
                this.showTimelinePage();
            } else {
                this.showWelcomePage()
            }

        },

        showWelcomePage: function() {
            $(this.el).html(this.welcomeView.render().el);
            if (!this.$("#photo-list .timeline-photo").is(':visible')) {
                this.$("#photo-list").fadeIn();
            }
        },

        showTimelinePage: function() {
            $(this.el).html(this.timelineView.render().el);
            if (!this.$("#photo-list .timeline-photo").is(':visible')) {
                this.$("#photo-list").fadeIn();
            }
        },

        showPhotoPage: function(photo) {
            this.updateHeader();
            this.singlePhotoView = new SinglePhotoView({model: photo});
            // Load landing page template
            $(this.el).html(this.singlePhotoView.render().el);
        }
    });

    var App = new AppView;


    var AppRouter = Backbone.Router.extend({
        routes: {
            "pic/:object_id": "getPic",
            "*actions": "defaultRoute"
        },

        getPic: function(object_id) {

            var query = new Parse.Query(Photo);
            query.include("user");
            query.get(object_id, {
                success: function(photo) {
                    App.showPhotoPage(photo);
                },
                error: function(object, error) {
                    console.error(error);
                    // The object was not retrieved successfully.
                    // error is a Parse.Error with an error code and description.
                    App.showError();
                }
            });
        },

        defaultRoute: function(actions) {
            App.showHomePage();
        }
    });

    // Initiate the router
    var app_router = new AppRouter();

    // Start Backbone history
    Backbone.history.start();
});

$(window).load(function(){
    $('.timeline-photo').find('a').find('img').each(function(){
        var imgClass = (this.width/this.height > 1) ? 'wide' : 'tall';
        $(this).addClass(imgClass);
    })
});


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
        avatarImageURL: function() {
            if (this.get("user").get("profilePictureMedium")) {
                return this.get("user").get("profilePictureMedium").url().replace(/http:\/\//,"https://s3.amazonaws.com/");
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
            $(this.el).html(this.template({
                "photo_url": this.model.photoURL(),
                "photo_image_url": this.model.photoImageURL(),
                "avatar_image_url": this.model.avatarImageURL(),
                "display_name": this.model.displayName(),
                "created_at": this.model.createdTime()
            }));

            return this;
        }
    });

    // Single Photo View, used to display the big photo in the landing page
    var SinglePhotoView = Parse.View.extend({

        template: _.template($("#big-photo-template").html()),
        metaDataLandingPageTemplate: _.template($("#meta-landingpage-template").html()),

        render: function() {
            $('head meta[property*="og:"]').remove();
            $('head').append(this.metaDataLandingPageTemplate({
                "photo_image_url": this.model.photoImageURL(),
                "photo_caption": "Shared a photo on Anypic",
                "page_url": "http://www.anypic.org/" + this.model.photoURL(),
            }));

            $(this.el).html(this.template({
                "photo_url": this.model.photoURL(),
                "photo_image_url": this.model.photoImageURL(),
                "avatar_image_url": this.model.avatarImageURL(),
                "display_name": this.model.displayName()
            }));

            return this;
        }
    });

    var TimelineView = Parse.View.extend({

        // Delegated events for creating new items, and clearing completed ones.

        el: ".content",

        initialize: function() {
            var self = this;
            var header = new LogOutHeader();

            _.bindAll(this, 'addOne', 'addAll');

            this.$el.html(_.template($("#timeline-template").html()));

            // Create our collection of Pictures
            this.photos = new PhotoList();
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
            this.photos.query.limit(8);
            this.photos.query.descending("createdAt");


            this.photos.bind('add', this.addOne);
            this.photos.bind('reset', this.addAll);
//            this.photos.bind('all', this.render);
//            Fetch all the todo items for this user35G
            this.photos.fetch();

        },



        // Re-rendering the App just means refreshing the statistics -- the rest
        // of the app doesn't change.
        render: function() {
            this.$("#photo-list").fadeIn();
            this.delegateEvents();
            return this;
        },

//        // Add a single todo item to the list by creating a view for it, and
//        // appending its element to the `<ul>`.
        addOne: function(photo) {
            var view = new PhotoView({model: photo});
            var rendered = view.render();
            this.$("#photo-list").append(rendered.el);
        },

        // Add all items in the Todos collection at once.
        addAll: function(collection, filter) {
            this.$("#photo-list").html("");
            this.photos.each(this.addOne);
        }


    });

    var LogOutHeader = Parse.View.extend({
        events: {
            "click .log-out": "logOut"
        },

        el: ".logout-navbar",

        initialize: function () {
            _.bindAll(this, "logOut");
            this.render();
        },
        // Logs out the user and shows the login view
        logOut: function(e) {
            Parse.User.logOut();
            window.location.reload();
            FB.destroySession(function(){});
            new LogInView();
            this.undelegateEvents();
            delete this;
        },
        render: function () {
            this.$el.html(_.template($("#logout-navbar-template").html()));
            this.delegateEvents();
        }
    });


    var LogInView = Parse.View.extend({
        events: {
            "click #facebook-sign-in": "logIn"
        },

        el: ".content",

        initialize: function () {
            _.bindAll(this, "logIn");
            this.render();
        },

        logIn: function (e) {
            var self = this;
            Parse.FacebookUtils.logIn("user_about_me", {
                success: function (user) {
                    console.log('login in success');
                    if (!user.existed()) {
                        console.log('login in user did not exists');
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
                                new TimelineView();
                                self.undelegateEvents();
                                delete this;
                            }
                        );
                    } else {
                        console.log('login in user did exists');
                        new TimelineView();
                        self.undelegateEvents();
                        delete this;
                    }
                },
                error: function (user, error) {
                    alert("User cancelled the Facebook login or did not fully authorize.");
                }
            });

            return false;
        },

        render: function () {
            this.$el.html(_.template($("#login-template").html()));
            this.delegateEvents();
        }
    });

    // The main view for the app
    var AppView = Parse.View.extend({
        // Instead of generating a new element, bind to the existing skeleton of
        // the App already present in the HTML.
        el: $("#panagram"),

        initialize: function () {
            this.render();
            if (!this.$("#photo-list .timeline-photo").is(':visible')) {
                this.$("#photo-list").fadeIn();
            }
        },

        render: function () {
            if (Parse.User.current()) {
                new TimelineView();
            } else {
                new LogInView();
            }
        }
    });

    new AppView;

});

$(window).load(function(){
    $('.timeline-photo').find('a').find('img').each(function(){
        var imgClass = (this.width/this.height > 1) ? 'wide' : 'tall';
        $(this).addClass(imgClass);
    })
});

$(document).ready(function() {
    $("abbr.timeago").timeago();
});
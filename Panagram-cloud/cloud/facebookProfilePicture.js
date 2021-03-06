// Validate Photos have a valid owner in the "user" pointer.
var Image = require("parse-image");

Parse.Cloud.beforeSave(Parse.User, function (request, response) {
        var user = request.object;

        var thumbnailJpg = "profileThumbnail.jpg";
        var pictureJpg = "profilePicture.jpg";
        var thumbnailKey = "profilePictureSmall";
        var pictureKey = "profilePictureMedium";
        var facebookIdKey = "facebookId";

        if (user.dirty(thumbnailKey) || user.dirty(pictureKey)) {
            response.error("You cannot set the pictures directly!");
            return;
        }

        if (!user.dirty(facebookIdKey)) {
            // The profile photo isn't being modified.
            response.success();
            return;
        }

        var facebookId = request.object.get(facebookIdKey);
        var url = "https://graph.facebook.com/" + facebookId + "/picture?width=320&height=320";
        console.log("Trying to get url:" + url);

        var followRedirectHttpRequest = function(url, success, error, tries){
            tries = typeof tries !== 'undefined' ?  tries : 0;
            tries = tries + 1

            Parse.Cloud.httpRequest({
                url: url,
                success: function (httpResponse) {
                    success(httpResponse);
                },
                error: function (httpResponse) {
                    if (tries < 5 && httpResponse && httpResponse.status && httpResponse.status == 302
                        && httpResponse.headers && httpResponse.headers.Location) {
                        console.log("Following redirect for " + url + " to " +httpResponse.headers.Location);
                        followRedirectHttpRequest(httpResponse.headers.Location, success, error, tries);
                    } else if (error){
                        error(httpResponse);
                    }
                }
            });
        };

        followRedirectHttpRequest(url,
            function(success){
                handleHttpResponse(success.buffer)},
            function(error){
                response.error("Failed to access url " + url + "even after redirects")}
        );

        var handleHttpResponse = function (buffer) {
            var promises = [];
            promises.push(scaleAndSave(buffer, 64, thumbnailJpg, thumbnailKey));
            promises.push(scaleAndSave(buffer, 280, pictureJpg, pictureKey));
            Parse.Promise.when(promises).then(function (result) {
                console.log("Scaled. We are done!");
                response.success();
            }, function (error) {
                response.error(error);
                console.log(error.toString())
            });
        };


        var scaleAndSave = function (imageData, resolution, filename, propertyName) {
            console.log("Got url");
            var mImage = new Image();
            return mImage.setData(imageData).then(function (image) {
                // Crop the image to the smaller of width or height.
                var size = Math.min(image.width(), image.height());
                return image.crop({
                    left: (image.width() - size) / 2,
                    top: (image.height() - size) / 2,
                    width: size,
                    height: size
                });
            }).then(function (image) {
                return image.scale({
                    width: resolution,
                    height: resolution
                });
            }).then(function (image) {
                // Make sure it's a JPEG to save disk space and bandwidth.
                return image.setFormat("JPEG");

            }).then(function (image) {
                // Get the image data in a Buffer.
                return image.data();

            }).then(function (buffer) {
                // Save the image into a new file.
                var base64 = buffer.toString("base64");
                var cropped = new Parse.File(filename, { base64: base64 });
                return cropped.save();

            }).then(function (cropped) {
                console.log("Resized picture saving to " + propertyName);
                // Attach the image file to the original object.
                user.set(propertyName, cropped);
            });
        };
    }
)
;

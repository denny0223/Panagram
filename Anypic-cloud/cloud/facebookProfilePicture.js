// Validate Photos have a valid owner in the "user" pointer.
var Image = require("parse-image");

Parse.Cloud.beforeSave(Parse.User, function (request, response) {
        var user = request.object;

        var thumbnailJpg = "profileThumbnail.jpg";
        var pictureJpg = "profilePicture.jpg";
        var thumbnailKey = "profilePictureSmall";
        var pictureKey = "profilePictureMedium";
        var urlKey = "profilePictureUrl";

        if (user.dirty(thumbnailKey) || user.dirty(pictureKey)){
            response.error("You cannot set the pictures directly!");
            return;
        }

        if (!user.dirty(urlKey)) {
            // The profile photo isn't being modified.
            response.success();
            return;
        }

        var url = user.get(urlKey);
        var facebookAkamai = "https://fbcdn-profile-a.akamaihd.net/"
        if (!(url.substring(0, facebookAkamai.length) === facebookAkamai)) {
            response.error();
            return;
        }

        Parse.Cloud.httpRequest({
            url: url
        }).then(function (response) {
            var promises = [];
            promises.push(scaleAndSave(response.buffer, 64, thumbnailJpg, thumbnailKey));
            promises.push(scaleAndSave(response.buffer, 280, pictureJpg, pictureKey));
            return Parse.Promise.when(promises);
        }).then(function (result) {
            response.success();
        }, function (error) {
            response.error(error);
        });


        var scaleAndSave = function (imageData, resolution, filename, propertyName) {
            var mImage = new Image();
            return mImage.setData(imageData).then(function(image){
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

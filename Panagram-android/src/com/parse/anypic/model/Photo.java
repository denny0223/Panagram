package com.parse.anypic.model;

import com.parse.ParseClassName;
import com.parse.ParseFile;
import com.parse.ParseObject;
import com.parse.ParseUser;

@ParseClassName("Photo")
public class Photo extends ParseObject {

    public static final String IMAGE = "image";
    public static final String USER = "user";
    public static final String THUMBNAIL = "thumbnail";

    public Photo() {
        // A default constructor is required.
    }

    public ParseFile getImage() {
        return getParseFile(IMAGE);
    }

    public void setImage(ParseFile file) {
        put(IMAGE, file);
    }

    public ParseUser getUser() {
        return getParseUser(USER);
    }

    public void setUser(ParseUser user) {
        put(USER, user);
    }

    public ParseFile getThumbnail() {
        return getParseFile(THUMBNAIL);
    }

    public void setThumbnail(ParseFile file) {
        put(THUMBNAIL, file);
    }

}

package com.parse.anypic;

import com.parse.ParseClassName;
import com.parse.ParseObject;
import com.parse.ParseUser;

/*
 * An extension of ParseObject that makes
 * it more convenient to access information
 * about a given Photo
 */

@ParseClassName("Activity")
public class Activity extends ParseObject {

    public Activity() {
        // A default constructor is required.
    }

    public ParseUser getFromUser(){
        return getParseUser("fromUser");
    }

    public void setFromUser(ParseUser user){
        put("fromUser", user);
    }

    public ParseUser getToUser(){
        return getParseUser("toUser");
    }

    public void setToUser(ParseUser user){
        put("toUser", user);
    }

    public String getType(){
        return getString("type");
    }

    public void setType(String t){
        put("type", t);
    }

    public String getContent(){
        return getString("content");
    }

    public void setContent(String c){
        put("content", c);
    }

    public ParseObject getPhoto(){
        return getParseObject("photo");
    }

    public void setPhoto(ParseObject pf){
        put("photo", pf);
    }
}


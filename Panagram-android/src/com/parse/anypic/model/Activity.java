package com.parse.anypic.model;

import com.parse.ParseClassName;
import com.parse.ParseObject;
import com.parse.ParseUser;

@ParseClassName("Activity")
public class Activity extends ParseObject {

    public static final String FROM_USER = "fromUser";
    public static final String TO_USER = "toUser";
    public static final String TYPE = "type";
    public static final String CONTENT = "content";
    public static final String PHOTO = "photo";

    public static final String TYPE_LIKE = "like";

    public Activity() {
        // A default constructor is required.
    }

    public ParseUser getFromUser(){
        return getParseUser(FROM_USER);
    }

    public void setFromUser(ParseUser user){
        put(FROM_USER, user);
    }

    public ParseUser getToUser(){
        return getParseUser(TO_USER);
    }

    public void setToUser(ParseUser user){
        put(TO_USER, user);
    }

    public String getType(){
        return getString(TYPE);
    }

    public void setType(String t){
        put(TYPE, t);
    }

    public String getContent(){
        return getString(CONTENT);
    }

    public void setContent(String c){
        put(CONTENT, c);
    }

    public ParseObject getPhoto(){
        return getParseObject(PHOTO);
    }

    public void setPhoto(ParseObject pf){
        put(PHOTO, pf);
    }
}


package com.parse.anypic;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.parse.ParseFile;
import com.parse.ParseQuery;
import com.parse.ParseQueryAdapter;
import com.parse.ParseUser;
import com.parse.anypic.model.ParseColumn;
import com.parse.anypic.model.Photo;
import com.squareup.picasso.Picasso;

/*
 * The UserViewAdapter is an extension of ParseQueryAdapter
 * that has a custom layout for Anypic photos for the current user
 */

public class UserViewAdapter extends ParseQueryAdapter<Photo> {

    public UserViewAdapter(Context context) {
        super(context, new ParseQueryAdapter.QueryFactory<Photo>() {
            public ParseQuery<Photo> create() {

                // Get the current user's photos
                ParseQuery<Photo> photosFromCurrentUserQuery = new ParseQuery<Photo>(Photo.class.getSimpleName());
                photosFromCurrentUserQuery.whereEqualTo(Photo.USER, ParseUser.getCurrentUser());
                photosFromCurrentUserQuery.whereExists(Photo.THUMBNAIL);

                photosFromCurrentUserQuery.include(Photo.USER);
                photosFromCurrentUserQuery.orderByDescending(ParseColumn.CREATED_AT);

                return photosFromCurrentUserQuery;
            }
        });
    }

    /**
     * This class is overridden to provide a custom view for each item in the
     * User's List View. It sets the user's profile picture, the user name,
     * and then displays the actual photo.
     *
     * See user_list_item.xml for the layout file
     *
     * @see com.parse.ParseQueryAdapter#getItemView(com.parse.ParseObject, android.view.View, android.view.ViewGroup)
     */
    @Override
    public View getItemView(Photo photo, View v, ViewGroup parent) {

        if (v == null) {
            v = View.inflate(getContext(), R.layout.home_list_item, null);
        }

        super.getItemView(photo, v, parent);

        // Set up the user's profile picture
        ImageView fbPhotoView = (ImageView) v.findViewById(R.id.user_thumbnail);
        ParseUser user = photo.getUser();
        Picasso.with(getContext())
            .load("https://graph.facebook.com/" + user.getString(ParseColumn.USER_FACEBOOK_ID) + "/picture?type=square")
            .into(fbPhotoView);

        // Set up the username
        TextView usernameView = (TextView) v.findViewById(R.id.user_name);
        usernameView.setText((String) user.get(ParseColumn.USER_DISPLAY_NAME));

        // Set up the actual photo
        ImageView anypicPhotoView = (ImageView) v.findViewById(R.id.photo);
        ParseFile photoFile = photo.getImage();

        // TODO (future) - get image bitmap, then set the image view with setImageBitmap()
        // we can use the decodeBitmap tricks to reduce the size to save memory

        if (photoFile != null) {
            Picasso.with(getContext())
                .load(photoFile.getUrl())
                .placeholder(new ColorDrawable(Color.LTGRAY))
                .into(anypicPhotoView);
        } else { // Clear ParseImageView if an object doesn't have a photo
            anypicPhotoView.setImageResource(android.R.color.transparent);
        }

        TextView likeCount = (TextView) v.findViewById(R.id.like_count);
        likeCount.setOnTouchListener(new OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    v.setBackgroundColor(Color.LTGRAY);
                } else {
                    v.setBackgroundColor(Color.TRANSPARENT);
                }
                return false;
            }
        });

        likeCount.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
            }
        });

        return v;
    }

}
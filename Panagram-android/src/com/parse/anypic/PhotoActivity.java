package com.parse.anypic;

import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.widget.ImageView;
import android.widget.TextView;

import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.squareup.picasso.Picasso;

import java.util.List;

public class PhotoActivity extends android.app.Activity {

    public static final String INTENT_EXTRA_PHOTO = "photo";

    android.app.Activity mActivity = this;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_photo);

        final ImageView photoView = (ImageView) findViewById(R.id.photo);
        final ImageView fbPhotoView = (ImageView) findViewById(R.id.user_thumbnail);
        final TextView usernameView = (TextView) findViewById(R.id.user_name);
        final TextView likeCountView = (TextView) findViewById(R.id.like_count);

        Intent intent = getIntent();
        String photoObjectId = intent.getStringExtra(INTENT_EXTRA_PHOTO);

        ParseQuery<Photo> query = new ParseQuery<Photo>("Photo");
        query.whereEqualTo("objectId", photoObjectId);
        query.include("user");

        query.getFirstInBackground(new GetCallback<Photo>() {

            @Override
            public void done(final Photo photo, ParseException e) {
                ParseUser user = photo.getUser();
                Picasso.with(mActivity)
                    .load("https://graph.facebook.com/" + user.getString("facebookId") + "/picture?type=square")
                    .into(fbPhotoView);

                usernameView.setText((String) user.get("displayName"));

                ParseFile photoFile = photo.getImage();
                if (photoFile != null) {
                    Picasso.with(mActivity)
                        .load(photoFile.getUrl())
                        .placeholder(new ColorDrawable(Color.LTGRAY))
                        .into(photoView);
                } else { // Clear ParseImageView if an object doesn't have a photo
                    photoView.setImageResource(android.R.color.transparent);
                }

                ParseQuery<Activity> likeQuery = new ParseQuery<Activity>("Activity");
                likeQuery.whereEqualTo("type", "like");
                likeQuery.include("fromUser");
                likeQuery.whereExists("photo");
                likeQuery.whereEqualTo("photo", photo);
                likeQuery.findInBackground(new FindCallback<Activity>() {

                    @Override
                    public void done(List<Activity> activities, ParseException e) {
                        boolean isLiked = false;

                        likeCountView.setText(String.valueOf(activities.size()));
                        for (Activity activity : activities) {
                            if (activity.getFromUser().getUsername()
                                    .equals(ParseUser.getCurrentUser().getUsername())) {
                                isLiked = true;
                            }
                        }

                        if (isLiked) {
                            setLiked(likeCountView);
                        } else {
                            setUnliked(likeCountView, photo);
                        }
                    }
                });
                    }
                });
    }

    public void setUnliked(TextView v, final Photo photo) {
        v.setClickable(true);
        v.setCompoundDrawablesWithIntrinsicBounds(R.drawable.ic_like, 0, 0, 0);

        v.setOnTouchListener(new OnTouchListener() {

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

        v.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                TextView likeView = (TextView) v;
                int like = Integer.valueOf((String) likeView.getText());
                likeView.setText(String.valueOf(++like));

                setLiked(likeView);

                Activity likeActivity = new Activity();
                likeActivity.setFromUser(ParseUser.getCurrentUser());
                likeActivity.setToUser(photo.getUser());
                likeActivity.setPhoto(photo);
                likeActivity.setType("like");
                likeActivity.saveEventually();
            }
        });
    }

    public void setLiked(TextView v) {
        v.setCompoundDrawablesWithIntrinsicBounds(R.drawable.ic_liked, 0, 0, 0);
        v.setClickable(false);
        v.setOnTouchListener(null);
    }

}

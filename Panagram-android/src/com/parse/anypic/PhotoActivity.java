package com.parse.anypic;

import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.parse.DeleteCallback;
import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseQuery;
import com.parse.ParseQueryAdapter.OnQueryLoadListener;
import com.parse.ParseUser;
import com.parse.SaveCallback;
import com.parse.anypic.model.Activity;
import com.parse.anypic.model.ParseColumn;
import com.parse.anypic.model.Photo;
import com.parse.anypic.util.ViewPressEffectHelper;
import com.squareup.picasso.Picasso;

import java.util.List;

public class PhotoActivity extends android.app.Activity {

    public static final String INTENT_EXTRA_PHOTO = "photo";

    android.app.Activity mActivity = this;
    Photo mPhoto;
    Activity mLikeActivity;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_photo);
        getActionBar().hide();

        final ImageView photoView = (ImageView) findViewById(R.id.photo);
        final ImageView fbPhotoView = (ImageView) findViewById(R.id.user_thumbnail);
        final TextView usernameView = (TextView) findViewById(R.id.user_name);
        final TextView likeCountView = (TextView) findViewById(R.id.like_count);
        final ProgressBar loadingProgress = (ProgressBar) findViewById(R.id.loading_progress);
        final ListView commentListView = (ListView) findViewById(R.id.comment_list);
        final EditText commentEditText = (EditText) findViewById(R.id.comment);
        final Button sendButton = (Button) findViewById(R.id.btn_send);
        final ProgressBar sendingProgress = (ProgressBar) findViewById(R.id.sending_progress);

        Intent intent = getIntent();
        String photoObjectId = intent.getStringExtra(INTENT_EXTRA_PHOTO);

        ViewPressEffectHelper.attach(likeCountView);

        ParseQuery<Photo> query = new ParseQuery<Photo>(Photo.class.getSimpleName());
        query.whereEqualTo(ParseColumn.OBJECT_ID, photoObjectId);
        query.include(Photo.USER);

        query.getFirstInBackground(new GetCallback<Photo>() {

            @Override
            public void done(final Photo photo, ParseException e) {
                mPhoto = photo;
                ParseUser user = photo.getUser();
                Picasso.with(mActivity)
                    .load("https://graph.facebook.com/" + user.getString(ParseColumn.USER_FACEBOOK_ID)
                            + "/picture?type=square")
                    .into(fbPhotoView);

                usernameView.setText((String) user.get(ParseColumn.USER_DISPLAY_NAME));

                ParseFile photoFile = photo.getImage();
                if (photoFile != null) {
                    Picasso.with(mActivity)
                        .load(photoFile.getUrl())
                        .placeholder(new ColorDrawable(Color.LTGRAY))
                        .into(photoView);
                } else { // Clear ParseImageView if an object doesn't have a photo
                    photoView.setImageResource(android.R.color.transparent);
                }

                ParseQuery<Activity> likeQuery = new ParseQuery<Activity>(Activity.class.getSimpleName());
                likeQuery.whereEqualTo(Activity.TYPE, Activity.TYPE_LIKE);
                likeQuery.include(Activity.FROM_USER);
                likeQuery.whereExists(Activity.PHOTO);
                likeQuery.whereEqualTo(Activity.PHOTO, photo);
                likeQuery.findInBackground(new FindCallback<Activity>() {

                    @Override
                    public void done(List<Activity> activities, ParseException e) {

                        likeCountView.setText(String.valueOf(activities.size()));
                        for (Activity activity : activities) {
                            if (activity.getFromUser().getUsername()
                                    .equals(ParseUser.getCurrentUser().getUsername())) {
                                mLikeActivity = activity;
                            }
                        }

                        if (mLikeActivity != null) {
                            setLiked(likeCountView);
                        } else {
                            setUnliked(likeCountView);
                        }
                    }
                });
                final CommentListAdapter commentListAdapter = new CommentListAdapter(mActivity, photo);
                commentListView.setAdapter(commentListAdapter);
                commentListAdapter.setPaginationEnabled(false);
                commentListAdapter.addOnQueryLoadListener(new OnQueryLoadListener<Activity>() {

                    @Override
                    public void onLoaded(List<Activity> arg0, Exception arg1) {
                        loadingProgress.setVisibility(View.GONE);
                        commentListView.setSmoothScrollbarEnabled(true);
                        commentListView.smoothScrollToPosition(commentListView.getBottom());
                    }

                    @Override
                    public void onLoading() {
                    }
                });

                sendButton.setOnClickListener(new OnClickListener() {

                    @Override
                    public void onClick(View v) {
                        if (!commentEditText.getText().toString().replaceAll("\\s", "").isEmpty()) {
                            sendButton.setVisibility(View.GONE);
                            sendingProgress.setVisibility(View.VISIBLE);

                            Activity commentActivity = new Activity();
                            commentActivity.setContent(commentEditText.getText().toString());
                            commentActivity.setFromUser(ParseUser.getCurrentUser());
                            commentActivity.setToUser(photo.getUser());
                            commentActivity.setPhoto(photo);
                            commentActivity.setType(Activity.TYPE_COMMENT);
                            commentActivity.saveInBackground(new SaveCallback() {

                                @Override
                                public void done(ParseException arg0) {
                                    sendButton.setVisibility(View.VISIBLE);
                                    sendingProgress.setVisibility(View.GONE);
                                    commentListAdapter.loadObjects();
                                }
                            });

                            commentEditText.setText("");
                        }
                    }
                });
            }
        });
    }

    public void setUnliked(TextView v) {
        v.setCompoundDrawablesWithIntrinsicBounds(R.drawable.ic_like, 0, 0, 0);

        v.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                v.setClickable(false);

                final TextView likeView = (TextView) v;
                int like = Integer.valueOf((String) likeView.getText());
                likeView.setText(String.valueOf(++like));
                likeView.setCompoundDrawablesWithIntrinsicBounds(R.drawable.ic_liked, 0, 0, 0);

                mLikeActivity = new Activity();
                mLikeActivity.setFromUser(ParseUser.getCurrentUser());
                mLikeActivity.setToUser(mPhoto.getUser());
                mLikeActivity.setPhoto(mPhoto);
                mLikeActivity.setType(Activity.TYPE_LIKE);
                mLikeActivity.saveInBackground(new SaveCallback() {

                    @Override
                    public void done(ParseException arg0) {
                        setLiked(likeView);
                    }
                });

            }
        });
    }

    public void setLiked(TextView v) {
        v.setCompoundDrawablesWithIntrinsicBounds(R.drawable.ic_liked, 0, 0, 0);

        v.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                v.setClickable(false);
                final TextView likeView = (TextView) v;
                int like = Integer.valueOf((String) likeView.getText());
                likeView.setText(String.valueOf(--like));
                likeView.setCompoundDrawablesWithIntrinsicBounds(R.drawable.ic_like, 0, 0, 0);

                mLikeActivity.deleteInBackground(new DeleteCallback() {

                    @Override
                    public void done(ParseException arg0) {
                        setUnliked(likeView);
                    }
                });
                mLikeActivity = null;

            }
        });
    }

}

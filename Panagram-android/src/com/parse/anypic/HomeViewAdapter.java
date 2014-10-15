package com.parse.anypic;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.parse.DeleteCallback;
import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseQuery;
import com.parse.ParseQueryAdapter;
import com.parse.ParseUser;
import com.parse.SaveCallback;
import com.parse.anypic.model.Activity;
import com.parse.anypic.model.ParseColumn;
import com.parse.anypic.model.Photo;
import com.parse.anypic.util.ViewPressEffectHelper;
import com.squareup.picasso.Picasso;

import java.util.List;

/*
 * The HomeViewAdapter is an extension of ParseQueryAdapter
 * that has a custom layout for Anypic photos in the home
 * list view.
 */

public class HomeViewAdapter extends ParseQueryAdapter<Photo> {

    public HomeViewAdapter(Context context) {
        super(context, new ParseQueryAdapter.QueryFactory<Photo>() {
            public ParseQuery<Photo> create() {

                ParseQuery<Photo> query = new ParseQuery<Photo>(Photo.class.getSimpleName());
                query.whereExists(Photo.IMAGE);
                query.include(Photo.USER);
                query.orderByDescending(ParseColumn.CREATED_AT);

                return query;
            }
        });
    }

    /**
     * This class is overridden to provide a custom view for each item in the
     * Home List View. It sets the user's profile picture, their user name,
     * and then displays the actual photo.
     *
     * See home_list_item.xml for the layout file
     *
     * @see com.parse.ParseQueryAdapter#getItemView(com.parse.ParseObject, android.view.View, android.view.ViewGroup)
     */
    @Override
    public View getItemView(final Photo photo, View v, ViewGroup parent) {

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

        final TextView likeCountView = (TextView) v.findViewById(R.id.like_count);
        final TextView commentCountView = (TextView) v.findViewById(R.id.comment_count);

        ParseQuery<Activity> activitiesQuery = new ParseQuery<Activity>(Activity.class.getSimpleName());
        activitiesQuery.include(Activity.FROM_USER);
        activitiesQuery.whereExists(Activity.PHOTO);
        activitiesQuery.whereEqualTo(Activity.PHOTO, photo);
        activitiesQuery.findInBackground(new FindCallback<Activity>() {

            @Override
            public void done(List<Activity> activities, ParseException e) {
                int likeCount = 0, commentCount = 0;
                Activity likeActivity = null;

                for (Activity activity : activities) {
                    if (activity.getType().equals(Activity.TYPE_LIKE)) {
                        likeCount++;
                        if (activity.getFromUser().getUsername()
                                .equals(ParseUser.getCurrentUser().getUsername())) {
                            likeActivity = activity;
                        }
                    } else if (activity.getType().equals(Activity.TYPE_COMMENT)) {
                        commentCount++;
                    }
                }

                likeCountView.setText(String.valueOf(likeCount));
                ViewPressEffectHelper.attach(likeCountView);
                commentCountView.setText(String.valueOf(commentCount));

                if (likeActivity != null) {
                    setLiked(likeCountView, photo, likeActivity);
                } else {
                    setUnliked(likeCountView, photo);
                }
            }
        });


//        final ImageView iv=anypicPhotoView;
//        ViewTreeObserver vto = iv.getViewTreeObserver();
//        vto.addOnPreDrawListener(new ViewTreeObserver.OnPreDrawListener() {
//            public boolean onPreDraw() {
//                Log.i(AnypicApplication.TAG, "*** Photo height: " + iv.getMeasuredHeight() + " width: " + iv.getMeasuredWidth());
//                return true;
//            }
//        });
        return v;
    }

    public void setUnliked(TextView v, final Photo photo) {
        v.setCompoundDrawablesWithIntrinsicBounds(R.drawable.ic_like, 0, 0, 0);
        v.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                v.setClickable(false);
                final TextView likeView = (TextView) v;
                int like = Integer.valueOf((String) likeView.getText());
                likeView.setText(String.valueOf(++like));
                likeView.setCompoundDrawablesWithIntrinsicBounds(R.drawable.ic_liked, 0, 0, 0);

                final Activity likeActivity = new Activity();
                likeActivity.setFromUser(ParseUser.getCurrentUser());
                likeActivity.setToUser(photo.getUser());
                likeActivity.setPhoto(photo);
                likeActivity.setType(Activity.TYPE_LIKE);
                likeActivity.saveInBackground(new SaveCallback() {

                    @Override
                    public void done(ParseException arg0) {
                        setLiked(likeView, photo, likeActivity);
                    }
                });

            }
        });
    }

    public void setLiked(TextView v, final Photo photo, final Activity likeActivity) {
        v.setCompoundDrawablesWithIntrinsicBounds(R.drawable.ic_liked, 0, 0, 0);
        v.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                v.setClickable(false);
                final TextView likeView = (TextView) v;
                int like = Integer.valueOf((String) likeView.getText());
                likeView.setText(String.valueOf(--like));
                likeView.setCompoundDrawablesWithIntrinsicBounds(R.drawable.ic_like, 0, 0, 0);

                likeActivity.deleteInBackground(new DeleteCallback() {

                    @Override
                    public void done(ParseException arg0) {
                        setUnliked(likeView, photo);
                    }
                });

            }
        });
    }

}

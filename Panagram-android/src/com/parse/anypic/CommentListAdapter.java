package com.parse.anypic;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.parse.ParseQuery;
import com.parse.ParseQuery.CachePolicy;
import com.parse.ParseQueryAdapter;
import com.parse.ParseUser;
import com.parse.anypic.model.Activity;
import com.parse.anypic.model.ParseColumn;
import com.parse.anypic.model.Photo;
import com.squareup.picasso.Picasso;

public class CommentListAdapter extends ParseQueryAdapter<Activity> {

    public CommentListAdapter(Context context, final Photo photo) {
        super(context, new ParseQueryAdapter.QueryFactory<Activity>() {
            public ParseQuery<Activity> create() {

                ParseQuery<Activity> photoCommentQuery = new ParseQuery<Activity>(Activity.class.getSimpleName());
                photoCommentQuery.whereEqualTo(Activity.PHOTO, photo);
                photoCommentQuery.whereEqualTo(Activity.TYPE, Activity.TYPE_COMMENT);
                photoCommentQuery.whereExists(Activity.CONTENT);

                photoCommentQuery.include(Activity.FROM_USER);
                photoCommentQuery.orderByAscending(ParseColumn.CREATED_AT);

                photoCommentQuery.setCachePolicy(CachePolicy.NETWORK_ELSE_CACHE);

                return photoCommentQuery;
            }
        });
        setPaginationEnabled(false);
    }

    @Override
    public View getItemView(Activity activity, View v, ViewGroup parent) {

        if (v == null) {
            v = View.inflate(getContext(), R.layout.comment_list_item, null);
        }

        super.getItemView(activity, v, parent);

        ImageView fbPhotoView = (ImageView) v.findViewById(R.id.user_thumbnail);
        TextView usernameView = (TextView) v.findViewById(R.id.user_name);
        TextView commentMessage = (TextView) v.findViewById(R.id.comment_msg);
        TextView commentTime = (TextView) v.findViewById(R.id.datetime);

        ParseUser user = activity.getFromUser();
        Picasso.with(getContext())
            .load("https://graph.facebook.com/" + user.getString(ParseColumn.USER_FACEBOOK_ID) + "/picture?type=square")
            .into(fbPhotoView);

        usernameView.setText((String) user.get(ParseColumn.USER_DISPLAY_NAME));
        commentMessage.setText(activity.getContent());
        commentTime.setText(activity.getCreatedAt().toString());

        return v;
    }

}
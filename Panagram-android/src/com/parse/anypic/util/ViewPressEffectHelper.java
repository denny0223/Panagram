package com.parse.anypic.util;

import android.os.Build;
import android.view.MotionEvent;
import android.view.View;
import android.view.animation.AlphaAnimation;

/**
 *
 * View Press Effect Helper
 * - usage : do some simple press effect like iOS
 *
 * Simple Usage:
 * ImageView img = (ImageView) findViewById(R.id.img);
 * ViewPressEffectHelper.attach(img)
 *
 * @author Lam @ HongKong
 *
 */
public class ViewPressEffectHelper {

	public static void attach(View view){
		view.setOnTouchListener(new View.OnTouchListener() {

			@Override
			public boolean onTouch(View v, MotionEvent event) {
				switch (event.getAction()) {
				case MotionEvent.ACTION_DOWN: {
					if (Build.VERSION.SDK_INT < 11) {
						final AlphaAnimation animation = new AlphaAnimation(1.0f, 0.5f);
						animation.setDuration(100);
						animation.setFillAfter(true);
						v.startAnimation(animation);
					} else
						v.setAlpha(0.5f);
				}
				break;

				case MotionEvent.ACTION_UP:
				case MotionEvent.ACTION_CANCEL:{
					if (Build.VERSION.SDK_INT < 11) {
						final AlphaAnimation animation = new AlphaAnimation(0.5f, 1.0f);
						animation.setDuration(100);
						animation.setFillAfter(true);
						v.startAnimation(animation);
					} else
						v.setAlpha(1.0f);
				}
				break;
				}

				return false;
			}
		});
	}
}

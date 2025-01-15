package org.ychernysh.greeting;

import android.app.Activity;
import android.os.Bundle;

public class GreetingActivity extends Activity {
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.greeting);
	}
}
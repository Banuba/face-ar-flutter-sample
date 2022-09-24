package com.banuba.far.flutter.sample.face_ar_flutter_sample

import androidx.annotation.NonNull
import com.banuba.sdk.manager.BanubaSdkManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    companion object {
        const val TAG = "SampleAndroid"
    }

    private val banubaSdkManager by lazy(LazyThreadSafetyMode.NONE) {
        // Init Face AR BanubaSdkManager and create new instance.
        // Your app should use only one instance of BanubaSdkManager and deinitialize it
        // when the user leaves the screen with Face AR.
        BanubaSdkManager.initialize(this, getString(R.string.banuba_sdk_token))
        BanubaSdkManager(applicationContext)
    }

    override fun onDestroy() {
        super.onDestroy()
        BanubaSdkManager.deinitialize()
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                BanubaPlatformCameraView.VIEW_TYPE,
                BanubaPlatformCameraViewFactory(
                    flutterEngine.dartExecutor.binaryMessenger,
                    banubaSdkManager
                )
            )
    }
}



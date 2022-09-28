package com.banuba.far.flutter.sample.face_ar_flutter_sample

import android.content.Context
import androidx.annotation.NonNull
import com.banuba.sdk.manager.BanubaSdkManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class MainActivity : FlutterActivity() {
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

private class BanubaPlatformCameraViewFactory(
    private val messenger: BinaryMessenger,
    private val banubaSdkManager: BanubaSdkManager
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(
        context: Context,
        id: Int,
        o: Any?
    ): PlatformView = BanubaPlatformCameraView(context, messenger, banubaSdkManager, id)
}



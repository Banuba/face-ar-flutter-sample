package com.banuba.far.flutter.sample.face_ar_flutter_sample

import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import com.banuba.sdk.entity.RecordedVideoInfo
import com.banuba.sdk.manager.BanubaSdkManager
import com.banuba.sdk.manager.IEventCallback
import com.banuba.sdk.types.Data
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class MainActivity : FlutterActivity() {

    companion object {
        const val TAG = "FlutterFar"
    }

    private val banubaEventCallback = object : IEventCallback {
        override fun onVideoRecordingFinished(videoInfo: RecordedVideoInfo) {
            val message =
                "Video recording finished. File = ${videoInfo.filePath}, duration = ${videoInfo.recordedLength}"
            Log.d(TAG, message)
            Toast.makeText(applicationContext, message, Toast.LENGTH_SHORT).show()
        }

        override fun onVideoRecordingStatusChange(isStarted: Boolean) {
            Log.d(TAG, "Video recording status changed. isRecording = $isStarted")
        }

        override fun onCameraOpenError(e: Throwable) {
            // Implement custom error handling here
            Log.w(TAG, "Error while opening camera", e)
        }

        override fun onImageProcessed(imageBitmpa: Bitmap) {}

        override fun onEditingModeFaceFound(faceFound: Boolean) {}

        override fun onHQPhotoReady(photoBitmap: Bitmap) {}

        override fun onEditedImageReady(imageBitmap: Bitmap) {}

        override fun onFrameRendered(data: Data, width: Int, height: Int) {}

        override fun onScreenshotReady(screenshotBitmap: Bitmap) {}

        override fun onCameraStatus(isOpen: Boolean) {}
    }

    private val banubaSdkManager by lazy(LazyThreadSafetyMode.NONE) {
        // Init Face AR BanubaSdkManager and create new instance.
        // Your app should use only one instance of BanubaSdkManager and deinitialize it
        // when the user leaves the screen with Face AR.
        BanubaSdkManager.initialize(this, getString(R.string.banuba_sdk_token))
        BanubaSdkManager(applicationContext).apply {
            setCallback(banubaEventCallback)
        }
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



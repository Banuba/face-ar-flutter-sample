package com.banuba.far.flutter.sample.face_ar_flutter_sample

import android.content.Context
import android.net.Uri
import android.util.Log
import android.view.SurfaceHolder
import android.view.SurfaceView
import android.view.View
import com.banuba.sdk.camera.Facing
import com.banuba.sdk.manager.BanubaSdkManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class BanubaPlatformCameraViewFactory(
    private val messenger: BinaryMessenger,
    private val banubaSdkManager: BanubaSdkManager
) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(
        context: Context,
        id: Int,
        o: Any?
    ): PlatformView = BanubaPlatformCameraView(context, messenger, banubaSdkManager, id)
}

class BanubaPlatformCameraView internal constructor(
    context: Context,
    messenger: BinaryMessenger,
    private val banubaSdkManager: BanubaSdkManager,
    viewId: Int
) : PlatformView, MethodChannel.MethodCallHandler {

    companion object {
        const val VIEW_TYPE = "banuba.facear.flutter/camera_view"
    }

    private val surfaceView: SurfaceView
    private val methodChannel: MethodChannel

    init {
        surfaceView = SurfaceView(context).apply {
            id = View.generateViewId()
        }

        surfaceView.holder.addCallback(object : SurfaceHolder.Callback {
            override fun surfaceCreated(holder: SurfaceHolder) {
                Log.d(MainActivity.TAG, "BanubaCameraView. surfaceCreated")
            }

            override fun surfaceChanged(
                holder: SurfaceHolder,
                format: Int,
                width: Int,
                height: Int
            ) {
                Log.d(MainActivity.TAG, "BanubaCameraView. surfaceChanged")
            }

            override fun surfaceDestroyed(holder: SurfaceHolder) {
                Log.d(MainActivity.TAG, "BanubaCameraView. surfaceDestroyed")
            }
        })

        methodChannel = MethodChannel(messenger, "${VIEW_TYPE}_$viewId").apply {
            setMethodCallHandler(this@BanubaPlatformCameraView)
        }
    }

    override fun getView(): View {
        Log.d(MainActivity.TAG, "BanubaCameraView. getView")
        return surfaceView
    }

    override fun onFlutterViewAttached(flutterView: View) {
        Log.d(MainActivity.TAG, "BanubaCameraView. onFlutterViewAttached = $flutterView")
        super.onFlutterViewAttached(flutterView)
    }

    override fun onFlutterViewDetached() {
        Log.d(MainActivity.TAG, "BanubaCameraView. onFlutterViewDetached")
        super.onFlutterViewDetached()
    }

    override fun onMethodCall(
        methodCall: MethodCall,
        result: MethodChannel.Result
    ) {
        val method = methodCall.method
        Log.d(MainActivity.TAG, "BanubaCameraView. onMethodCall = $method")
        when (method) {
            "applyEffect" -> handleApplyEffect(methodCall, result)
            "setFrontFacing" -> handleFacing(methodCall, result)
            "open" -> handleOpenCamera(methodCall, result)
            "close" -> handleCloseCamera(methodCall, result)
            else -> result.notImplemented()
        }
    }

    private fun handleApplyEffect(
        methodCall: MethodCall,
        result: MethodChannel.Result
    ) {
        val effectName = methodCall.arguments as? String
        if (effectName == null || effectName.isBlank()) {
            banubaSdkManager.effectManager.loadAsync("")
        } else {
            banubaSdkManager.effectManager.loadAsync(buildEffectUri(effectName).toString())
        }
        result.success(null)
    }

    private fun handleOpenCamera(
        methodCall: MethodCall,
        result: MethodChannel.Result
    ) {
        Log.d(MainActivity.TAG, "BanubaCameraView. Open Camera")

        banubaSdkManager.attachSurface(surfaceView)
        banubaSdkManager.openCamera()
        banubaSdkManager.effectPlayer.playbackPlay()

        result.success(null)
    }

    private fun handleCloseCamera(
        methodCall: MethodCall,
        result: MethodChannel.Result
    ) {
        Log.d(MainActivity.TAG, "BanubaCameraView. Close Camera")
        banubaSdkManager.effectPlayer.playbackPause()
        banubaSdkManager.releaseSurface()
        banubaSdkManager.closeCamera()

        result.success(null)
    }

    private fun handleFacing(
        methodCall: MethodCall,
        result: MethodChannel.Result
    ) {
        Log.d(MainActivity.TAG, "BanubaCameraView. Handle facing")

        val frontFacing = methodCall.arguments as Boolean
        if (frontFacing) {
            banubaSdkManager.cameraFacing = Facing.FRONT
        } else {
            banubaSdkManager.cameraFacing = Facing.BACK
        }
    }

    override fun dispose() {}

    private fun buildEffectUri(name: String) = Uri.parse(BanubaSdkManager.getResourcesBase())
        .buildUpon()
        .appendPath("effects")
        .appendPath(name)
        .build()
}
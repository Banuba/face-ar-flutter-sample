package com.banuba.far.flutter.sample.face_ar_flutter_sample

import android.content.Context
import android.net.Uri
import android.view.SurfaceView
import android.view.View
import com.banuba.sdk.camera.Facing
import com.banuba.sdk.entity.ContentRatioParams
import com.banuba.sdk.manager.BanubaSdkManager
import io.flutter.embedding.android.FlutterSurfaceView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class BanubaPlatformCameraView internal constructor(
    context: Context,
    messenger: BinaryMessenger,
    private val banubaSdkManager: BanubaSdkManager,
    viewId: Int
) : PlatformView, MethodChannel.MethodCallHandler {

    companion object {
        const val VIEW_TYPE = "banuba.facear.flutter/camera_view"

        private const val DEFAULT_VIDEO_WIDTH = 720
        private const val DEFAULT_VIDEO_HEIGHT = 1280
    }

    private val surfaceView: SurfaceView
    private val methodChannel: MethodChannel

    init {
        surfaceView = FlutterSurfaceView(context)
        methodChannel = MethodChannel(messenger, "${VIEW_TYPE}_$viewId").apply {
            setMethodCallHandler(this@BanubaPlatformCameraView)
        }

        banubaSdkManager.attachSurface(surfaceView)
    }

    override fun getView(): View = surfaceView

    override fun dispose() {
        banubaSdkManager.releaseSurface()
    }

    override fun onMethodCall(
        methodCall: MethodCall,
        result: MethodChannel.Result
    ) {
        when (methodCall.method) {
            "applyEffect" -> handleApplyEffect(methodCall, result)
            "setFrontFacing" -> handleFacing(methodCall, result)
            "open" -> handleOpenCamera(result)
            "close" -> handleCloseCamera(result)
            "startVideoRecording" -> handleStartVideoRecording(methodCall, result)
            "stopVideoRecording" -> handleStopVideoRecording(result)
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

    private fun handleOpenCamera(result: MethodChannel.Result) {
        banubaSdkManager.effectPlayer.playbackPlay()
        banubaSdkManager.openCamera()
        result.success(null)
    }

    private fun handleCloseCamera(result: MethodChannel.Result) {
        banubaSdkManager.effectPlayer.playbackPause()
        banubaSdkManager.closeCamera()

        result.success(null)
    }

    private fun handleFacing(
        methodCall: MethodCall,
        result: MethodChannel.Result
    ) {
        val frontFacing = methodCall.arguments as Boolean
        if (frontFacing) {
            banubaSdkManager.cameraFacing = Facing.FRONT
        } else {
            banubaSdkManager.cameraFacing = Facing.BACK
        }

        result.success(null)
    }

    private fun handleStartVideoRecording(
        methodCall: MethodCall,
        result: MethodChannel.Result
    ) {
        val map = methodCall.arguments as Map<*, *>
        val filePath = map["filePath"] as String
        val recordAudio = map["recordAudio"] as Boolean

        banubaSdkManager.startVideoRecording(
            filePath,
            recordAudio,
            ContentRatioParams(DEFAULT_VIDEO_WIDTH, DEFAULT_VIDEO_HEIGHT, false),
            1f // speed
        )
        result.success(null)
    }

    private fun handleStopVideoRecording(result: MethodChannel.Result) {
        banubaSdkManager.stopVideoRecording()
        result.success(null)
    }

    private fun buildEffectUri(name: String) = Uri.parse(BanubaSdkManager.getResourcesBase())
        .buildUpon()
        .appendPath("effects")
        .appendPath(name)
        .build()
}
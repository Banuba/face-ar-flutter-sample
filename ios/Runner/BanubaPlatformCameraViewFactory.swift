import Flutter
import UIKit
import BNBSdkApi

class BanubaPlatformCameraViewFactory: NSObject, FlutterPlatformViewFactory {
  let messenger: FlutterBinaryMessenger
  let viewType: String
  let sdkManager: BanubaSdkManager
    
  init(
    messenger: FlutterBinaryMessenger,
    viewType: String,
    sdkManager: BanubaSdkManager
  ) {
    self.messenger = messenger
    self.viewType = viewType
    self.sdkManager = sdkManager
    
    sdkManager.setup(configuration: EffectPlayerConfiguration())
    
    super.init()
  }
  
  deinit {
      sdkManager.destroyEffectPlayer()
    }
  
  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    let flutterNativeView = BanubaPlatformCameraView(
      frame: frame,
      viewIdentifier: viewId,
      arguments: args,
      binaryMessenger: messenger,
      sdkManager: sdkManager,
      viewType: viewType
    )

    return flutterNativeView
  }
}

class BanubaPlatformCameraView: NSObject, FlutterPlatformView {
  private let renderTarget: EffectPlayerView
  let sdkManager: BanubaSdkManager
  let viewType: String
  private var channel: FlutterMethodChannel?
  
  init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?,
    binaryMessenger messenger: FlutterBinaryMessenger?,
    sdkManager: BanubaSdkManager,
    viewType: String
  ) {
    self.sdkManager = sdkManager
      self.viewType = viewType
    renderTarget = EffectPlayerView(frame: frame)
    super.init()
      
    listenFlutterCalls(viewId: viewId, messenger: messenger)
  }
  
  func view() -> UIView {
    return renderTarget
  }
    
    private func listenFlutterCalls(viewId: Int64, messenger: FlutterBinaryMessenger?) {
      channel = FlutterMethodChannel(
        name: "\(viewType)_\(viewId)",
        binaryMessenger: messenger!
      )
      channel?.setMethodCallHandler { [weak self] methodCall, resultHandler in
        guard let self = self else { return }
        
        switch methodCall.method {
        case "open": self.handleOpenCall(methodCall, result: resultHandler)
        case "close": self.handleCloseCall(methodCall, result: resultHandler)
        case "applyEffect": self.handleApplyEffectCall(methodCall, result: resultHandler)
        case "setFrontFacing": self.handleFrontFacingCall(methodCall, result: resultHandler)
        default: resultHandler(FlutterMethodNotImplemented)
        }
      }
    }
    
    private func handleOpenCall(_ methodCall: FlutterMethodCall, result: FlutterResult) {
      sdkManager.input.startCamera()
      sdkManager.startEffectPlayer()
      sdkManager.setRenderTarget(
        view: renderTarget,
        playerConfiguration: EffectPlayerConfiguration()
      )
      result(nil)
    }
    
    private func handleCloseCall(_ methodCall: FlutterMethodCall, result: FlutterResult) {
      sdkManager.input.stopCamera()
      sdkManager.stopEffectPlayer()
      sdkManager.renderTarget = nil
      result(nil)
    }
    
    private func handleApplyEffectCall(_ methodCall: FlutterMethodCall, result: FlutterResult) {
      let effectName = methodCall.arguments as? String ?? ""
      sdkManager.effectManager()?.load(effectName)
      result(nil)
    }
    
    private func handleFrontFacingCall(_ methodCall: FlutterMethodCall, result: FlutterResult) {
      guard let isFront = methodCall.arguments as? Bool else {
        result(FlutterMethodNotImplemented)
        return
      }
      
      let cameraSessionType: CameraSessionType = isFront ? .FrontCameraSession : .BackCameraSession
      sdkManager.input.setCameraSessionType(cameraSessionType)
      result(nil)
    }
}

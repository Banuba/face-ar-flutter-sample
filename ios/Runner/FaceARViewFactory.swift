import Flutter
import UIKit
import BNBSdkApi

fileprivate enum FlutterMethod: String {
  case open
  case close
  case applyEffect
  case setFrontFacing
}

class FaceARViewFactory: NSObject, FlutterPlatformViewFactory {
  let messenger: FlutterBinaryMessenger
  let viewType: String
  
  private let sdkManager = BanubaSdkManager()
  private var channel: FlutterMethodChannel?
  private weak var renderTarget: EffectPlayerView?
  
  init(
    messenger: FlutterBinaryMessenger,
    viewType: String
  ) {
    self.messenger = messenger
    self.viewType = viewType
    
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
    let flutterNativeView = FlutterNativeView(
      frame: frame,
      viewIdentifier: viewId,
      arguments: args,
      binaryMessenger: messenger
    )
		
    listenFlutterCalls(viewId: viewId)
    
    self.renderTarget = flutterNativeView.renderTarget
    
    return flutterNativeView
  }
  
  private func listenFlutterCalls(viewId: Int64) {
    channel = FlutterMethodChannel(
      name: "\(viewType)_\(viewId)",
      binaryMessenger: messenger
    )
    channel?.setMethodCallHandler { [weak self] methodCall, resultHandler in
      guard
        let self = self,
        let method = FlutterMethod(rawValue: methodCall.method)
      else {
        resultHandler(FlutterMethodNotImplemented)
        return
      }
      
      switch method {
      case .open: self.handleOpenCall(methodCall, result: resultHandler)
      case .close: self.handleCloseCall(methodCall, result: resultHandler)
      case .applyEffect: self.handleApplyEffectCall(methodCall, result: resultHandler)
      case .setFrontFacing: self.handleFronFacingCall(methodCall, result: resultHandler)
      }
    }
  }
  
  private func handleOpenCall(_ methodCall: FlutterMethodCall, result: FlutterResult) {
    guard let renderTarget = renderTarget else {
      print("Render target is not initialized")
      result(FlutterMethodNotImplemented)
      return
    }
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
    guard let effectName = methodCall.arguments as? String else {
      result(FlutterMethodNotImplemented)
      return
    }
    
    sdkManager.effectManager()?.load(effectName)
    result(nil)
  }
  
  private func handleFronFacingCall(_ methodCall: FlutterMethodCall, result: FlutterResult) {
    guard let isFront = methodCall.arguments as? Bool else {
      result(FlutterMethodNotImplemented)
      return
    }
    
    let cameraSessionType: CameraSessionType = isFront ? .FrontCameraSession : .BackCameraSession
    sdkManager.input.setCameraSessionType(cameraSessionType)
    result(nil)
  }
}

class FlutterNativeView: NSObject, FlutterPlatformView {
  let renderTarget: EffectPlayerView
  
  init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?,
    binaryMessenger messenger: FlutterBinaryMessenger?
  ) {
    renderTarget = EffectPlayerView(frame: frame)
    
    super.init()
  }
  
  func view() -> UIView {
    return renderTarget
  }
}

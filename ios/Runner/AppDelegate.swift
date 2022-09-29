import UIKit
import Flutter
import BNBSdkApi

let banubaClientToken = /*@START_MENU_TOKEN@*/"SET FACE AR TOKEN"/*@END_MENU_TOKEN@*/

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    BanubaSdkManager.initialize(
        resourcePath: [Bundle.main.bundlePath + "/bnb-resources",
                       Bundle.main.bundlePath + "/effects"],
        clientTokenString: banubaClientToken
    )
    
    GeneratedPluginRegistrant.register(with: self)

    weak var registrar = self.registrar(forPlugin: "FaceAR-plugin")

    let viewType = "banuba.facear.flutter/camera_view"
    let factory = FaceARViewFactory(
      messenger: registrar!.messenger(),
      viewType: viewType
    )
    self.registrar(forPlugin: "FaceAR-view-plugin")!.register(
        factory,
        withId: viewType
    )
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

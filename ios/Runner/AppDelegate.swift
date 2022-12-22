import UIKit
import Flutter
import AVKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
	var acela: AcelaWebViewController?
	let authBridge = AuthBridge()
	let encoderBridge = EncoderBridge()
	let hasBridge = HASBridge()
	override func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		acela = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AcelaWebViewController") as? AcelaWebViewController

		acela?.viewDidLoad()

		let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
		authBridge.initiate(controller: controller, window: window, acela: acela)
		encoderBridge.initiate(controller: controller, window: window, acela: acela)
		hasBridge.initiate(controller: controller, window: window, acela: acela)

		GeneratedPluginRegistrant.register(with: self)
		return super.application(application, didFinishLaunchingWithOptions: launchOptions)
	}

//	override func applicationDidBecomeActive(_ application: UIApplication) {
//		if (TSSocket.shared.tusClient == nil) {
//			TSSocket.shared.connect()
//		}
//	}
}

import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
	var acela: AcelaWebViewController?
	let authBridge = AuthBridge()
	override func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		acela = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AcelaWebViewController") as? AcelaWebViewController
		acela?.viewDidLoad()

		let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
		authBridge.initiate(controller: controller, window: window, acela: acela)

		GeneratedPluginRegistrant.register(with: self)
		return super.application(application, didFinishLaunchingWithOptions: launchOptions)
	}
}

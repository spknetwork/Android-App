//
//  AuthBridge.swift
//  Runner
//
//  Created by Sagar on 01/05/22.
//

import UIKit
import Flutter

class AuthBridge {
	var window: UIWindow?
	var acela: AcelaWebViewController?

	func initiate(controller: FlutterViewController, window: UIWindow?, acela: AcelaWebViewController?) {
		self.window = window
		self.acela = acela
		let authChannel = FlutterMethodChannel(
			name: "com.example.acela/auth",
			binaryMessenger: controller.binaryMessenger
		)
		authChannel.setMethodCallHandler({
			[weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
			// Note: this method is invoked on the UI thread.
			guard
				call.method == "validate",
				let arguments = call.arguments as? NSDictionary,
				let username = arguments ["username"] as? String,
				let password = arguments["postingKey"] as? String
			else {
				result(FlutterMethodNotImplemented)
				return
			}
			self?.authenticate(username: username, postingKey: password, result: result)
		})
	}

	private func authenticate(username: String, postingKey: String, result: @escaping FlutterResult) {
		guard let acela = acela else {
			result(FlutterError(code: "ERROR",
													message: "Error setting up Hive",
													details: nil))
			return
		}
		acela.validatePostingKey(username: username, postingKey: postingKey) { response in
			result(response)
		}
	}
}

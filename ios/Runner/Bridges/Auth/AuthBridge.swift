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
			switch (call.method) {
				case "validate":
					guard
						let arguments = call.arguments as? NSDictionary,
						let username = arguments ["username"] as? String,
						let password = arguments["postingKey"] as? String
					else {
						result(FlutterMethodNotImplemented)
						return
					}
					self?.authenticate(username: username, postingKey: password, result: result)
				case "encryptedToken":
					guard
						let arguments = call.arguments as? NSDictionary,
						let username = arguments ["username"] as? String,
						let password = arguments["postingKey"] as? String,
						let encryptedToken = arguments["encryptedToken"] as? String
					else {
						result(FlutterMethodNotImplemented)
						return
					}
					self?.decryptMemo(username: username, postingKey: password, encryptedMemo: encryptedToken, result: result)
				case "postVideo":
					guard
						let arguments = call.arguments as? NSDictionary,
						let data = arguments ["data"] as? String,
						let password = arguments["postingKey"] as? String
					else {
						result(FlutterMethodNotImplemented)
						return
					}
					self?.postVideo(data: data, postingKey: password, result: result)
				default: debugPrint("do nothing")
			}
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

	private func decryptMemo(
		username: String,
		postingKey: String,
		encryptedMemo: String,
		result: @escaping FlutterResult
	) {
		guard let acela = acela else {
			result(FlutterError(code: "ERROR",
													message: "Error setting up Hive",
													details: nil))
			return
		}
		acela.decryptMemo(username: username, postingKey: postingKey, encryptedMemo: encryptedMemo) { response in
			result(response)
		}
	}

	private func postVideo(data: String, postingKey: String, result: @escaping FlutterResult) {
		guard let acela = acela else {
			result(FlutterError(code: "ERROR",
													message: "Error Uploading video from iOS native bridge",
													details: nil))
			return
		}
		acela.postVideo(data: data, postingKey: postingKey) { response in
			result(response)
		}
	}
}

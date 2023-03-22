//
//  Bridge.swift
//  Runner
//
//  Created by Sagar on 24/11/22.
//

import Foundation
import UIKit
import Flutter

class HASBridge {
	var window: UIWindow?
	var acela: AcelaWebViewController?

	func initiate(
		controller: FlutterViewController,
		window: UIWindow?,
		acela: AcelaWebViewController?
	) {
		self.window = window
		self.acela = acela
		let authChannel = FlutterMethodChannel(
			name: "blog.hive.auth/bridge",
			binaryMessenger: controller.binaryMessenger
		)

		authChannel.setMethodCallHandler({
			[weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
			// Note: this method is invoked on the UI thread.
			switch (call.method) {
				case "getRedirectUri":
					guard
						let arguments = call.arguments as? NSDictionary,
						let username = arguments ["username"] as? String
					else {
						result(FlutterMethodNotImplemented)
						return
					}
					self?.getRedirectUri(username: username, result: result)
				case "getRedirectUriData":
					guard
						let arguments = call.arguments as? NSDictionary,
						let username = arguments ["username"] as? String
					else {
						result(FlutterMethodNotImplemented)
						return
					}
					self?.getRedirectUriData(username: username, result: result)
				case "getDecryptedHASToken":
					guard
						let arguments = call.arguments as? NSDictionary,
						let username = arguments ["username"] as? String,
						let authKey = arguments ["authKey"] as? String,
						let data = arguments ["data"] as? String
					else {
						result(FlutterMethodNotImplemented)
						return
					}
					self?.getDecryptedHASToken(username: username, authKey: authKey, data: data, result: result)
				case "getEncryptedChallenge":
					guard
						let arguments = call.arguments as? NSDictionary,
						let username = arguments ["username"] as? String,
						let authKey = arguments ["authKey"] as? String
					else {
						result(FlutterMethodNotImplemented)
						return
					}
					self?.getEncryptedChallenge(username: username, authKey: authKey, result: result)
				case "getDecryptedChallenge":
					guard
						let arguments = call.arguments as? NSDictionary,
						let username = arguments ["username"] as? String,
						let authKey = arguments ["authKey"] as? String,
						let data = arguments ["data"] as? String
					else {
						result(FlutterMethodNotImplemented)
						return
					}
					self?.getDecryptedChallenge(username: username, authKey: authKey, data: data, result: result)
				case "getUserInfo":
					self?.getUserInfo(result: result)
				default:
					result(FlutterMethodNotImplemented)
			}
		})
	}

	private func getDecryptedChallenge(username: String, authKey: String, data: String, result: @escaping FlutterResult) {
		guard let acela = acela else {
			result(FlutterError(code: "ERROR",
													message: "Error setting up Hive",
													details: nil))
			return
		}
		acela.getDecryptedChallenge(username: username, authKey: authKey, data: data) { string in
			result(string)
		}
	}

	private func getEncryptedChallenge(username: String, authKey: String, result: @escaping FlutterResult) {
		guard let acela = acela else {
			result(FlutterError(code: "ERROR",
													message: "Error setting up Hive",
													details: nil))
			return
		}
		acela.getEncryptedChallenge(username: username, authKey: authKey) { string in
			result(string)
		}
	}

	private func getDecryptedHASToken(username: String, authKey: String, data: String, result: @escaping FlutterResult) {
		guard let acela = acela else {
			result(FlutterError(code: "ERROR",
													message: "Error setting up Hive",
													details: nil))
			return
		}
		acela.getDecryptedHASToken(username: username, authKey: authKey, data: data) { string in
			result(string)
		}
	}

	private func getUserInfo(result: @escaping FlutterResult) {
		guard let acela = acela else {
			result(FlutterError(code: "ERROR",
													message: "Error setting up Hive",
													details: nil))
			return
		}
		acela.getUserInfo { string in
			result(string)
		}
	}

	private func getRedirectUri(username: String, result: @escaping FlutterResult) {
		guard let acela = acela else {
			result(FlutterError(code: "ERROR",
													message: "Error setting up Hive",
													details: nil))
			return
		}
		acela.getRedirectUri(username) { string in
			result(string)
		}
	}

	private func getRedirectUriData(username: String, result: @escaping FlutterResult) {
		guard let acela = acela else {
			result(FlutterError(code: "ERROR",
													message: "Error setting up Hive",
													details: nil))
			return
		}
		acela.getRedirectUriData(username) { string in
			debugPrint("Sending string back - \(string)")
			result(string)
		}
	}
}

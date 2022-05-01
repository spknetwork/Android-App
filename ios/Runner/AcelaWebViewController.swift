//
//  AcelaWebViewController.swift
//  Runner
//
//  Created by Sagar on 01/05/22.
//

import UIKit
import WebKit

class AcelaWebViewController: UIViewController {
	let acela = "acela"
	let config = WKWebViewConfiguration()
	let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
	var webView: WKWebView?
	var didFinish = false
	var postingKeyValidationHandler: ((Bool) -> Void)?

	override func viewDidLoad() {
		super.viewDidLoad()
		config.userContentController.add(self, name: acela)
		webView = WKWebView(frame: rect, configuration: config)
		webView?.navigationDelegate = self
		guard
			let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "public")
		else { return }
		let dir = url.deletingLastPathComponent()
		webView?.loadFileURL(url, allowingReadAccessTo: dir)
	}

	func validatePostingKey(
		username: String,
		postingKey: String,
		handler: @escaping (Bool) -> Void
	) {
		postingKeyValidationHandler = handler
		OperationQueue.main.addOperation {
			self.webView?.evaluateJavaScript("validateHiveKey('\(username)', '\(postingKey)')")
		}
	}
}

extension AcelaWebViewController: WKNavigationDelegate {
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		didFinish = true
	}
}

extension AcelaWebViewController: WKScriptMessageHandler {
	func userContentController(
		_ userContentController: WKUserContentController,
		didReceive message: WKScriptMessage
	) {
		guard message.name == acela else { return }
		guard let dict = message.body as? [String: AnyObject] else { return }
		guard let type = dict["type"] as? String else { return }
		switch type {
			case "validateHiveKey":
				guard
					let isValid = dict["valid"] as? Bool,
					let accountName = dict["accountName"] as? String,
					let postingKey = dict["postingKey"] as? String,
					let error = dict["error"] as? String
				else { return }
				debugPrint("Is it valid? \(isValid ? "TRUE" : "FALSE")")
				debugPrint("account name is \(accountName)")
				debugPrint("posting key is \(postingKey)")
				debugPrint("Error is \(error)")
				postingKeyValidationHandler?(isValid)
			default: debugPrint("Do nothing here.")
		}
	}
}

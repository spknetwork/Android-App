//
//  EncoderBridge.swift
//  Runner
//
//  Created by Sagar on 13/05/22.
//

import Foundation
import UIKit
import Flutter
import PhotosUI
import FYVideoCompressor
import MobileCoreServices

class EncoderBridge: NSObject {
	var window: UIWindow?
	var acela: AcelaWebViewController?
	var controller: FlutterViewController?
	let picker = UIImagePickerController()

	func initiate(controller: FlutterViewController, window: UIWindow?, acela: AcelaWebViewController?) {
		self.window = window
		self.acela = acela
		self.controller = controller
		let encoderChannel = FlutterMethodChannel(
			name: "com.example.acela/encoder",
			binaryMessenger: controller.binaryMessenger
		)
		encoderChannel.setMethodCallHandler({
			[weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
			// Note: this method is invoked on the UI thread.
			guard
				call.method == "video",
				let arguments = call.arguments as? NSDictionary,
				let username = arguments ["username"] as? String,
				let password = arguments["postingKey"] as? String
			else {
				result(FlutterMethodNotImplemented)
				return
			}
			self?.video(username: username, postingKey: password, result: result)
		})
	}

	private func video(username: String, postingKey: String, result: @escaping FlutterResult) {
		guard let acela = acela else {
			result(FlutterError(code: "ERROR",
													message: "Error setting up Hive",
													details: nil))
			return
		}
//		acela.validatePostingKey(username: username, postingKey: postingKey) { response in
//			guard
//				let data = response.data(using: .utf8),
//				let object = try? JSONDecoder().decode(ValidateHiveKeyResponse.self, from: data),
//				object.valid == true
//			else {
//				result(response)
//				return
//			}
//			showPicker()
//		}
		showPicker()
	}

	func showPicker() {
		if #available(iOS 14, *) {
			PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status) in
				DispatchQueue.main.async {
					self.showUI(for: status)
				}
			}
		} else {
			showVideoPicker()
		}
	}

	func showUI(for status: PHAuthorizationStatus) {
		switch status {
		case .authorized:
			showVideoPicker()
		case .limited:
			showVideoPicker()
		case .restricted:
			showVideoPicker()
		case .denied:
			print("Denied")
		case .notDetermined:
			print("Denied")
			break
		@unknown default:
			break
		}
	}

	func showVideoPicker() {
		if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
			picker.sourceType = .photoLibrary
			picker.mediaTypes = ["public.movie"]
			picker.allowsEditing = false
			picker.delegate = self
			controller?.present(picker, animated: true, completion: nil)
		}
	}

	func convertToMP4(url: URL) {
		let fm = FileManager.default
		var comps = url.lastPathComponent.components(separatedBy: CharacterSet(charactersIn: "."))
		comps.removeLast()
		let fileName = comps.joined(separator: ".")
		let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
		let docDirFilePath = "\(docDir)/\(fileName).mp4"
		try? fm.removeItem(atPath: docDirFilePath)
		let docDirFileUrl = URL(fileURLWithPath: docDirFilePath)
		let asset = AVURLAsset(url: url)
		let export = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
		export?.outputURL = docDirFileUrl
		export?.outputFileType = AVFileType.mp4
		export?.exportAsynchronously(completionHandler: {
			debugPrint("DocDir url - \(docDirFileUrl.absoluteString)")
		})
	}
}

extension EncoderBridge: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(
		_ picker: UIImagePickerController,
		didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
	) {
		if let type = info[UIImagePickerController.InfoKey.mediaType] as? String,
			 type == kUTTypeMovie as String,
			 let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
			picker.dismiss(animated: true) {
				debugPrint("URL of media is \(url.debugDescription)")
				self.convertToMP4(url: url)
				// self.encodingOptions(url)
				// self.performSegue(withIdentifier: "encode", sender: url)
			}
		} else {
			picker.dismiss(animated: true, completion: nil)
		}
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}

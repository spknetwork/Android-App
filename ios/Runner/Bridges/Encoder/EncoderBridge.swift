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
	var result: FlutterResult?

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
		acela.validatePostingKey(username: username, postingKey: postingKey) { [weak self] response in
			guard
				let data = response.data(using: .utf8),
				let object = try? JSONDecoder().decode(ValidateHiveKeyResponse.self, from: data),
				object.valid == true
			else {
				result(response)
				return
			}
			self?.showPicker(result: result)
		}
	}

	func showPicker(result: @escaping FlutterResult) {
		if #available(iOS 14, *) {
			PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status) in
				DispatchQueue.main.async {
					self.showUI(for: status, result: result)
				}
			}
		} else {
			showVideoPicker(result: result)
		}
	}

	func showUI(for status: PHAuthorizationStatus, result: @escaping FlutterResult) {
		switch status {
			case .authorized:
				showVideoPicker(result: result)
			case .limited:
				showVideoPicker(result: result)
			case .restricted:
				showVideoPicker(result: result)
			case .denied:
				result(FlutterError(code: "ERROR",
														message: "Please provide access. Go to Settings > Acela > Photos > Selected Photos / All Photos",
														details: nil))
			case .notDetermined:
				result(FlutterError(code: "ERROR",
														message: "Please provide access. Go to Settings > Acela > Photos > Selected Photos / All Photos.",
														details: nil))
				break
			@unknown default:
				break
		}
	}

	func showVideoPicker(result: @escaping FlutterResult) {
		if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
			picker.sourceType = .photoLibrary
			picker.mediaTypes = ["public.movie"]
			picker.allowsEditing = false
			picker.delegate = self
			controller?.present(picker, animated: true, completion: nil)
			self.result = result
		} else {
			result(FlutterError(code: "ERROR",
													message: "Please provide access. Go to Settings > Acela > Photos > Selected Photos / All Photos.",
													details: nil))
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
			let asset = AVAsset(url: docDirFileUrl)
			let duration = asset.duration
			let durationTime = CMTimeGetSeconds(duration)
			debugPrint("Video duration is in seconds - \(durationTime) seconds")
			do {
				let attr = try FileManager.default.attributesOfItem(atPath: docDirFilePath)
				let fileSize = attr[FileAttributeKey.size] as! UInt64
				debugPrint("Video file size is - \(fileSize)")
				let responseString = VideoDataResponse.jsonStringFrom(size: Int(fileSize), duration: Int(durationTime), oFilename: "\(fileName).mp4", path: docDirFileUrl.absoluteString)
				self.result?(responseString)
			} catch {
				print("Error: \(error)")
			}
		})
	}
}

struct VideoDataResponse: Codable {
	let size: Int
	let duration: Int
	let oFilename: String
	let path: String

	static func jsonStringFrom(size: Int, duration: Int, oFilename: String, path: String) -> String? {
		let response = VideoDataResponse(
			size: size,
			duration: duration,
			oFilename: oFilename,
			path: path
		)
		guard let data = try? JSONEncoder().encode(response) else { return nil }
		guard let dataString = String(data: data, encoding: .utf8) else { return nil }
		return dataString
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
			}
		} else {
			picker.dismiss(animated: true, completion: nil)
			result?(FlutterError(code: "ERROR",
													 message: "Selection of media is not a video.",
													 details: nil))
		}
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
		result?(FlutterError(code: "ERROR",
												 message: "You cancelled selection of videos.",
												 details: nil))
	}
}

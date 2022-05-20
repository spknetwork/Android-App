//
//  VideoEncoderSizes.swift
//  Runner
//
//  Created by Sagar on 13/05/22.
//

import UIKit
import MobileCoreServices
import AVFoundation
import FYVideoCompressor

// 240p, 480p, 720p, 1080p, 1440p, 2160p
enum VideoQuality {
	case veryLow
	case low
	case medium
	case high
	case twoK
	case fourK

	var size: CGSize {
		switch self {
		case .veryLow: return CGSize(width: 240, height: 0)
		case .low: return CGSize(width: 480, height: 0)
		case .medium: return CGSize(width: 720, height: 0)
		case .high: return CGSize(width: 1080, height: 0)
		case .twoK: return CGSize(width: 1440, height: 0)
		case .fourK: return CGSize(width: 2160, height: 0)
		}
	}

	var stringValue: String {
		switch self {
		case .veryLow: return "veryLow"
		case .low: return "low"
		case .medium: return "medium"
		case .high: return "high"
		case .twoK: return "2K"
		case .fourK: return "4K"
		}
	}

	var intValue: Int {
		switch self {
		case .veryLow: return 0
		case .low: return 1
		case .medium: return 2
		case .high: return 3
		case .twoK: return 4
		case .fourK: return 5
		}
	}

	static func from(_ intValue: Int) -> VideoQuality {
		switch intValue {
		case 0: return .veryLow
		case 1: return .low
		case 2: return .medium
		case 3: return .high
		case 4: return .twoK
		default: return .low
		}
	}

	var bitrate: Int {
		switch self {
		case .veryLow: return 1000_000 // 1 mbps
		case .low: return 1250_000 // 1.25 mbps
		case .medium: return 5000_000 // 5 mbps
		case .high: return 8000_000 // 8 mbps
		case .twoK: return 16000_000 // 16 mbps
		case .fourK: return 35000_000 // 35 mbps
		}
	}

	var framerate: Float {
		switch self {
		case .veryLow: return 15
		case .low: return 17
		case .medium: return 22
		case .high: return 24
		case .twoK: return 25
		case .fourK: return 26
		}
	}

	var config: FYVideoCompressor.CompressionConfig {
		FYVideoCompressor.CompressionConfig(
			videoBitrate: bitrate,
			videomaxKeyFrameInterval: 10,
			fps: framerate,
			audioSampleRate: 44100,
			audioBitrate: 128_000,
			fileType: .mp4,
			scale: size)
	}
}

public extension URL {
	var fileSize: Int? {
		let value = try? resourceValues(forKeys: [.fileSizeKey])
		return value?.fileSize
	}

	var getThumbnail: UIImage? {
		do {
			let asset = AVURLAsset(url: self)
			let imageGenerator = AVAssetImageGenerator(asset: asset)
			imageGenerator.appliesPreferredTrackTransform = true

			// Swift 5.3
			let cgImage = try imageGenerator.copyCGImage(at: .zero,
																									 actualTime: nil)

			return UIImage(cgImage: cgImage)
		} catch {
			print(error.localizedDescription)

			return nil
		}
	}
}

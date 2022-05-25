//
//  ValidateHiveKeyResponse.swift
//  Runner
//
//  Created by Sagar on 02/05/22.
//

import Foundation

struct ValidateHiveKeyResponse: Codable {
	let valid: Bool
	let accountName: String
	let postingKey: String
	let error: String

	static func jsonStringFrom(dict: [String: AnyObject]) -> String? {
		guard
			let isValid = dict["valid"] as? Bool,
			let accountName = dict["accountName"] as? String,
			let postingKey = dict["postingKey"] as? String,
			let error = dict["error"] as? String
		else { return nil }
		let response = ValidateHiveKeyResponse(
			valid: isValid,
			accountName: accountName,
			postingKey: postingKey,
			error: error
		)
		guard let data = try? JSONEncoder().encode(response) else { return nil }
		guard let dataString = String(data: data, encoding: .utf8) else { return nil }
		return dataString
	}
}

struct DecryptMemoResponse: Codable {
	let accountName: String
	let decrypted: String
	let error: String

	static func jsonStringFrom(dict: [String: AnyObject]) -> String? {
		guard
			let accountName = dict["accountName"] as? String,
			let error = dict["error"] as? String,
			let decrypted = dict["decrypted"] as? String
		else { return nil }
		let response = DecryptMemoResponse(
			accountName: accountName,
			decrypted: decrypted,
			error: error
		)
		guard let data = try? JSONEncoder().encode(response) else { return nil }
		guard let dataString = String(data: data, encoding: .utf8) else { return nil }
		return dataString
	}
}

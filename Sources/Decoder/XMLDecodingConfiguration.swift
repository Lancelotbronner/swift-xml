//
//  XMLDecodingConfiguration.swift
//  swift-xml
//
//  Created by Christophe Bronner on 2025-07-16.
//

import Foundation

public extension XMLDecoder {
	/// The strategy to use for decoding `Date` values.
	enum DateDecodingStrategy: Sendable {
		/// Defer to `Date` for decoding. This is the default strategy.
		case deferredToDate
		
		/// Decode the `Date` as a UNIX timestamp from a XML number. This is the default strategy.
		case secondsSince1970
		
		/// Decode the `Date` as UNIX millisecond timestamp from a XML number.
		case millisecondsSince1970
		
		/// Decode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
		case iso8601
		
		/// Decode the `Date` as a string parsed by the given formatter.
		case formatted(DateFormatter)
		
		/// Decode the `Date` as a custom value decoded by the given closure.
		case custom(@Sendable (_ decoder: Decoder) throws -> Date)
		
		/// Decode the `Date` as a string parsed by the given formatter for the give key.
		static func keyFormatted(_ formatterForKey: @Sendable @escaping (CodingKey) throws -> DateFormatter?) -> XMLDecoder.DateDecodingStrategy {
			.custom { (decoder) -> Date in
				guard let codingKey = decoder.codingPath.last else {
					throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No Coding Path Found"))
				}
				
				guard let container = try? decoder.singleValueContainer(),
					  let text = try? container.decode(String.self) else {
					throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not decode date text"))
				}
				
				guard let dateFormatter = try formatterForKey(codingKey) else {
					throw DecodingError.dataCorruptedError(in: container, debugDescription: "No date formatter for date text")
				}
				
				if let date = dateFormatter.date(from: text) {
					return date
				} else {
					throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(text)")
				}
			}
		}
	}
	
	/// The strategy to use for decoding `Data` values.
	enum DataDecodingStrategy: Sendable {
		/// Defer to `Data` for decoding.
		case deferredToData
		
		/// Decode the `Data` from a Base64-encoded string. This is the default strategy.
		case base64
		
		/// Decode the `Data` as a custom value decoded by the given closure.
		case custom(@Sendable (_ decoder: Decoder) throws -> Data)
		
		/// Decode the `Data` as a custom value by the given closure for the give key.
		static func keyFormatted(_ formatterForKey: @escaping @Sendable (CodingKey) throws -> Data?) -> XMLDecoder.DataDecodingStrategy {
			.custom { (decoder) -> Data in
				guard let codingKey = decoder.codingPath.last else {
					throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No Coding Path Found"))
				}
				
				guard let container = try? decoder.singleValueContainer(),
					  let text = try? container.decode(String.self) else {
					throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not decode date text"))
				}
				
				guard let data = try formatterForKey(codingKey) else {
					throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode data string \(text)")
				}
				
				return data
			}
		}
	}
	
	/// The strategy to use for non-XML-conforming floating-point values (IEEE 754 infinity and NaN).
	enum NonConformingFloatDecodingStrategy: Sendable {
		/// Throw upon encountering non-conforming values. This is the default strategy.
		case `throw`
		
		/// Decode the values from the given representation strings.
		case convertFromString(positiveInfinity: String, negativeInfinity: String, nan: String)
	}
	
	/// The strategy to use for automatically changing the value of keys before decoding.
	enum KeyDecodingStrategy: Sendable {
		/// Use the keys specified by each type. This is the default strategy.
		case useDefaultKeys
		
		/// Convert from "snake_case_keys" to "camelCaseKeys" before attempting to match a key with the one specified by each type.
		///
		/// The conversion to upper case uses `Locale.system`, also known as the ICU "root" locale. This means the result is consistent regardless of the current user's locale and language preferences.
		///
		/// Converting from snake case to camel case:
		/// 1. Capitalizes the word starting after each `_`
		/// 2. Removes all `_`
		/// 3. Preserves starting and ending `_` (as these are often used to indicate private variables or other metadata).
		/// For example, `one_two_three` becomes `oneTwoThree`. `_one_two_three_` becomes `_oneTwoThree_`.
		///
		/// - Note: Using a key decoding strategy has a nominal performance cost, as each string key has to be inspected for the `_` character.
		case convertFromSnakeCase
		
		/// Provide a custom conversion from the key in the encoded JSON to the keys specified by the decoded types.
		/// The full path to the current decoding position is provided for context (in case you need to locate this key within the payload). The returned key is used in place of the last component in the coding path before decoding.
		/// If the result of the conversion is a duplicate key, then only one value will be present in the container for the type to decode from.
		case custom(@Sendable (_ codingPath: [CodingKey]) -> CodingKey)
		
		static func _convertFromSnakeCase(_ stringKey: String) -> String {
			guard !stringKey.isEmpty else { return stringKey }
			
			// Find the first non-underscore character
			guard let firstNonUnderscore = stringKey.firstIndex(where: { $0 != "_" }) else {
				// Reached the end without finding an _
				return stringKey
			}
			
			// Find the last non-underscore character
			var lastNonUnderscore = stringKey.index(before: stringKey.endIndex)
			while lastNonUnderscore > firstNonUnderscore && stringKey[lastNonUnderscore] == "_" {
				stringKey.formIndex(before: &lastNonUnderscore)
			}
			
			let keyRange = firstNonUnderscore...lastNonUnderscore
			let leadingUnderscoreRange = stringKey.startIndex..<firstNonUnderscore
			let trailingUnderscoreRange = stringKey.index(after: lastNonUnderscore)..<stringKey.endIndex
			
			let components = stringKey[keyRange].split(separator: "_")
			let joinedString : String
			if components.count == 1 {
				// No underscores in key, leave the word as is - maybe already camel cased
				joinedString = String(stringKey[keyRange])
			} else {
				joinedString = ([components[0].lowercased()] + components[1...].map { $0.capitalized }).joined()
			}
			
			// Do a cheap isEmpty check before creating and appending potentially empty strings
			let result : String
			if (leadingUnderscoreRange.isEmpty && trailingUnderscoreRange.isEmpty) {
				result = joinedString
			} else if (!leadingUnderscoreRange.isEmpty && !trailingUnderscoreRange.isEmpty) {
				// Both leading and trailing underscores
				result = String(stringKey[leadingUnderscoreRange]) + joinedString + String(stringKey[trailingUnderscoreRange])
			} else if (!leadingUnderscoreRange.isEmpty) {
				// Just leading
				result = String(stringKey[leadingUnderscoreRange]) + joinedString
			} else {
				// Just trailing
				result = joinedString + String(stringKey[trailingUnderscoreRange])
			}
			return result
		}
	}
}

extension XMLDecoder.KeyDecodingStrategy {
	func decode(_ codingPath: [any CodingKey]) -> any CodingKey {
		switch self {
		case .useDefaultKeys: codingPath.last!
		case .convertFromSnakeCase: _CodingKey(stringValue: Self._convertFromSnakeCase(codingPath.last!.stringValue))
		case .custom(let transform): transform(codingPath)
		}
	}
}

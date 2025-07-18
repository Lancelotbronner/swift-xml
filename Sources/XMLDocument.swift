//
//  XMLDocument.swift
//  swift-xml
//
//  Created by Christophe Bronner on 2024-12-30.
//

import Foundation

public struct XMLHeader {
	/// the XML standard that the produced document conforms to.
	var version: Double? = nil
	/// the encoding standard used to represent the characters in the produced document.
	var encoding: String? = nil
	/// indicates whetehr a document relies on information from an external source.
	var standalone: String? = nil
	
	init(version: Double? = nil) {
		self.version = version
	}
	
	init(version: Double?, encoding: String?, standalone: String? = nil) {
		self.version = version
		self.encoding = encoding
		self.standalone = standalone
	}
	
	func isEmpty() -> Bool {
		return version == nil && encoding == nil && standalone == nil
	}
	
	func toXML() -> String? {
		guard !self.isEmpty() else { return nil }
		
		var string = "<?xml "
		
		if let version = version {
			string += "version=\"\(version)\" "
		}
		
		if let encoding = encoding {
			string += "encoding=\"\(encoding)\" "
		}
		
		if let standalone = standalone {
			string += "standalone=\"\(standalone)\""
		}
		
		return string.trimmingCharacters(in: .whitespaces) + "?>\n"
	}
}









class _XMLElement {
	static let attributesKey = "___ATTRIBUTES"
	static let escapedCharacterSet = [("&", "&amp"), ("<", "&lt;"), (">", "&gt;"), ( "'", "&apos;"), ("\"", "&quot;")]
	
	var key: String
	var value: String? = nil
	var attributes: [String: String] = [:]
	var children: [String: [_XMLElement]] = [:]
	
	init(key: String, value: String? = nil, attributes: [String: String] = [:], children: [String: [_XMLElement]] = [:]) {
		self.key = key
		self.value = value
		self.attributes = attributes
		self.children = children
	}
	
	convenience init(key: String, value: Optional<CustomStringConvertible>, attributes: [String: CustomStringConvertible] = [:]) {
		self.init(key: key, value: value?.description, attributes: attributes.mapValues({ $0.description }), children: [:])
	}
	
	convenience init(key: String, children: [String: [_XMLElement]], attributes: [String: CustomStringConvertible] = [:]) {
		self.init(key: key, value: nil, attributes: attributes.mapValues({ $0.description }), children: children)
	}
	
	static func createRootElement(rootKey: String, object: NSObject) -> _XMLElement? {
		let element = _XMLElement(key: rootKey)
		
		if let object = object as? NSDictionary {
			_XMLElement.modifyElement(element: element, parentElement: nil, key: nil, object: object)
		} else if let object = object as? NSArray {
			_XMLElement.createElement(parentElement: element, key: rootKey, object: object)
		}
		
		return element
	}
	
	fileprivate static func createElement(parentElement: _XMLElement?, key: String, object: NSDictionary) {
		let element = _XMLElement(key: key)
		
		modifyElement(element: element, parentElement: parentElement, key: key, object: object)
	}
	
	fileprivate static func modifyElement(element: _XMLElement, parentElement: _XMLElement?, key: String?, object: NSDictionary) {
		element.attributes = (object[_XMLElement.attributesKey] as? [String: Any])?.mapValues({ String(describing: $0) }) ?? [:]
		
		let objects: [(String, NSObject)] = object.compactMap({
			guard let key = $0 as? String, let value = $1 as? NSObject, key != _XMLElement.attributesKey else { return nil }
			
			return (key, value)
		})
		
		for (key, value) in objects {
			if let dict = value as? NSDictionary {
				_XMLElement.createElement(parentElement: element, key: key, object: dict)
			} else if let array = value as? NSArray {
				_XMLElement.createElement(parentElement: element, key: key, object: array)
			} else if let string = value as? NSString {
				_XMLElement.createElement(parentElement: element, key: key, object: string)
			} else if let number = value as? NSNumber {
				_XMLElement.createElement(parentElement: element, key: key, object: number)
			} else {
				_XMLElement.createElement(parentElement: element, key: key, object: NSNull())
			}
		}
		
		if let parentElement = parentElement, let key = key {
			parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
		}
	}
	
	fileprivate static func createElement(parentElement: _XMLElement, key: String, object: NSArray) {
		let objects = object.compactMap({ $0 as? NSObject })
		objects.forEach({
			if let dict = $0 as? NSDictionary {
				_XMLElement.createElement(parentElement: parentElement, key: key, object: dict)
			} else if let array = $0 as? NSArray {
				_XMLElement.createElement(parentElement: parentElement, key: key, object: array)
			} else if let string = $0 as? NSString {
				_XMLElement.createElement(parentElement: parentElement, key: key, object: string)
			} else if let number = $0 as? NSNumber {
				_XMLElement.createElement(parentElement: parentElement, key: key, object: number)
			} else {
				_XMLElement.createElement(parentElement: parentElement, key: key, object: NSNull())
			}
		})
	}
	
	fileprivate static func createElement(parentElement: _XMLElement, key: String, object: NSNumber) {
		let element = _XMLElement(key: key, value: object.description)
		parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
	}
	
	fileprivate static func createElement(parentElement: _XMLElement, key: String, object: NSString) {
		let element = _XMLElement(key: key, value: object.description)
		parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
	}
	
	fileprivate static func createElement(parentElement: _XMLElement, key: String, object: NSNull) {
		let element = _XMLElement(key: key)
		parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
	}
	
	func flatten() -> [String: Any] {
		var node: [String: Any] = attributes
		
		for childElement in children {
			for child in childElement.value {
				if let content = child.value {
					if let oldContent = node[childElement.key] as? Array<Any> {
						node[childElement.key] = oldContent + [content]
						
					} else if let oldContent = node[childElement.key] {
						node[childElement.key] = [oldContent, content]
						
					} else {
						node[childElement.key] = content
					}
				} else if !child.children.isEmpty || !child.attributes.isEmpty {
					let newValue = child.flatten()
					
					if let existingValue = node[childElement.key] {
						if var array = existingValue as? Array<Any> {
							array.append(newValue)
							node[childElement.key] = array
						} else {
							node[childElement.key] = [existingValue, newValue]
						}
					} else {
						node[childElement.key] = newValue
					}
				}
			}
		}
		
		return node
	}
	
	func toXMLString(with header: XMLHeader? = nil, withCDATA cdata: Bool, ignoreEscaping: Bool = false) -> String {
		if let header = header, let headerXML = header.toXML() {
			return headerXML + _toXMLString(withCDATA: cdata)
		} else {
			return _toXMLString(withCDATA: cdata)
		}
	}
	
	fileprivate func _toXMLString(indented level: Int = 0, withCDATA cdata: Bool, ignoreEscaping: Bool = false) -> String {
		var string = String(repeating: " ", count: level * 4)
		string += "<\(key)"
		
		for (key, value) in attributes {
			string += " \(key)=\"\(value.escape(_XMLElement.escapedCharacterSet))\""
		}
		
		if let value = value {
			string += ">"
			if !ignoreEscaping {
				string += (cdata == true ? "<![CDATA[\(value)]]>" : "\(value.escape(_XMLElement.escapedCharacterSet))" )
			} else {
				string += "\(value)"
			}
			string += "</\(key)>"
		} else if !children.isEmpty {
			string += ">\n"
			
			for childElement in children {
				for child in childElement.value {
					string += child._toXMLString(indented: level + 1, withCDATA: cdata)
					string += "\n"
				}
			}
			
			string += String(repeating: " ", count: level * 4)
			string += "</\(key)>"
		} else {
			string += " />"
		}
		
		return string
	}
}

extension String {
	func escape(_ characterSet: [(character: String, escapedCharacter: String)]) -> String {
		var string = self
		
		for set in characterSet {
			string = string.replacingOccurrences(of: set.character, with: set.escapedCharacter, options: .literal)
		}
		
		return string
	}
}

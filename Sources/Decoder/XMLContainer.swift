//
//  XMLContainer.swift
//  swift-xml
//
//  Created by Christophe Bronner on 2025-07-16.
//

struct _XMLContainer {
	let element: _XMLElement2
	var affinity: XMLCodingAffinity
}

extension _XMLContainer {
	
	var value: String {
		element.value
	}
	
	var count: Int {
		switch affinity {
		case .none: element.attributes.count + element.children.count
		case .element: element.children.count
		case .attribute, .directive: element.attributes.count
		case .choice: element.children.isEmpty ? 0 : 1
		}
	}
	
	var keys: some Collection<String> {
		switch affinity {
		case .none: AnyCollection(element.attributes.keys + element.children.lazy.map(\.key))
		case .element: AnyCollection(element.children.map(\.key))
		case .attribute, .directive: AnyCollection(element.attributes.keys)
		case .choice: element.children.first.map { AnyCollection(CollectionOfOne($0.key)) } ?? AnyCollection(EmptyCollection())
		}
	}
	
	private func containsInChildren(_ key: some CodingKey) -> Bool {
		if let intValue = key.intValue {
			element.children.indices.contains(intValue)
		} else {
			element.children.contains { $0.key == key.stringValue }
		}
	}
	
	private func containsInAttributes(_ key: some CodingKey) -> Bool {
		if key.intValue != nil {
			false
		} else {
			element.attributes.contains { $0.key == key.stringValue }
		}
	}
	
	func contains(_ key: some CodingKey) -> Bool {
		switch affinity {
		case .none: containsInAttributes(key) || containsInChildren(key)
		case .element: containsInChildren(key)
		case .attribute, .directive: containsInAttributes(key)
		case .choice: element.key == key.stringValue
		}
	}
	
	func element(forKey key: String) -> _XMLElement2? {
		switch affinity {
		case .none: element.children.first { $0.key == key } ?? element
		case .element: element.children.first { $0.key == key }
		default: element
		}
	}
	
	func element(at i: Int) -> _XMLElement2? {
		switch affinity {
		case .none, .element: element.children.indices.contains(i) ? element.children[i] : nil
		default: nil
		}
	}
	
	func element(for codingKey: any CodingKey) -> _XMLElement2? {
		if let intValue = codingKey.intValue {
			element(at: intValue)
		} else {
			element(forKey: codingKey.stringValue)
		}
	}
}

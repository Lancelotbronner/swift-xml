//
//  XMLContainer.swift
//  swift-xml
//
//  Created by Christophe Bronner on 2025-07-16.
//

@usableFromInline enum _XMLContainer {
	/// Provides elements, attributes and value.
	case node(_XMLElement2)
	case elements([_XMLElement2])
	case attributes([String : String])
	case ambiguous(_XMLAmbiguousValue)
	case value(String)
	/// Can choose how to decode an element based on its key.
	case choice(_XMLElement2)
}

extension _XMLContainer {
	
	init?(key: String, on node: _XMLElement2) {
		let attribute = node.attributes[key]
		let children = node.children.filter { $0.key == key }
		
		guard !children.isEmpty else {
			guard let attribute else { return nil }
			self = .value(attribute)
			return
		}
		
		if let attribute {
			self = .ambiguous(_XMLAmbiguousValue(key: key, attribute: attribute, elements: children))
		} else if children.count == 1 {
			self = .node(children[0])
		} else {
			self = .elements(children)
		}
	}
	
	init?(on elements: some Collection<_XMLElement2>) {
		switch elements.count {
		case 0: return nil
		case 1: self = .node(elements.first!)
		default: self = .elements(Array(elements))
		}
	}
	
	var key: String? {
		switch self {
		case let .node(node): node.key
		case let .choice(choice): choice.key
		case let .ambiguous(ambiguous): ambiguous.key
		case .elements, .attributes, .value: nil
		}
	}
	
	var value: String? {
		switch self {
		case let .node(node): node.value
		case let .ambiguous(ambiguous): ambiguous.attribute
		case let .value(value): value
		case .elements, .attributes, .choice: nil
		}
	}
	
	var count: Int {
		switch self {
		case let .node(node): node.attributes.count + node.children.count
		case let .ambiguous(ambiguous): ambiguous.elements.count
		case let .elements(elements): elements.count
		case let .attributes(attributes): attributes.count
		case .choice: 1
		case .value: 0
		}
	}
	
	var keys: some Collection<String> {
		switch self {
		case let .node(node): AnyCollection(node.attributes.keys + node.children.map(\.key))
		case let .ambiguous(ambiguous): AnyCollection(ambiguous.elements.map(\.key))
		case let .elements(elements): AnyCollection(elements.lazy.map(\.key))
		case let .attributes(attributes): AnyCollection(attributes.keys)
		case let .choice(element): AnyCollection(CollectionOfOne(element.key))
		case .value: AnyCollection(EmptyCollection<String>())
		}
	}
	
	var elements: [_XMLElement2] {
		switch self {
		case let .node(node): node.children
		case let .elements(elements): elements
		case let .ambiguous(ambiguous): ambiguous.elements
		case .attributes, .choice, .value: []
		}
	}
	
	func applying(affinity: XMLAffinity) -> _XMLContainer {
		switch self {
		case let .node(node):
			switch affinity {
			case .node: self
			case .attributes, .directive: .attributes(node.attributes)
			case .elements: .elements(node.children)
			case .value: .value(node.value)
			case .choice: .choice(node)
			}
		case let .ambiguous(ambiguous):
			switch affinity {
			case .elements: .elements(ambiguous.elements)
			case .attributes: .attributes([ambiguous.key: ambiguous.attribute])
			case .node, .value, .choice, .directive: self
			}
		default: self
		}
	}
	
	func contains(named key: String) -> Bool {
		switch self {
		case let .node(node): node.attributes.keys.contains(key) || node.containsChild(key)
		case let .ambiguous(ambiguous): ambiguous.elements.contains { $0.key == key }
		case let .elements(elements): elements.contains { $0.key == key }
		case let .attributes(attributes): attributes.keys.contains(key)
		case let .choice(choice): choice.key == key
		case .value: false
		}
	}
	
	func contains(at i: Int) -> Bool {
		switch self {
		case let .node(node): node.containsChild(at: i)
		case let .ambiguous(ambiguous): ambiguous.elements.indices.contains(i)
		case let .elements(elements): elements.indices.contains(i)
		case .attributes, .choice, .value: false
		}
	}
	
	func contains(_ key: some CodingKey) -> Bool {
		if let intValue = key.intValue { contains(at: intValue) }
		else { contains(named: key.stringValue) }
	}
	
	func container(named key: String) -> _XMLContainer? {
		switch self {
		case let .node(node): _XMLContainer(key: key, on: node)
		case .ambiguous: applying(affinity: .elements).container(named: key)
		case let .elements(elements): _XMLContainer(on: elements.filter { $0.key == key })
		case let .attributes(attributes): attributes[key].map(_XMLContainer.value)
		case let .choice(choice):
			switch key {
			case choice.key: self
			case "_0": .node(choice)
			default: nil
			}
		case .value: nil
		}
	}
	
	func container(at i: Int) -> _XMLContainer? {
		switch self {
		case let .node(node): node.children.indices.contains(i) ? .node(node.children[i]) : nil
		case let .elements(elements): elements.indices.contains(i) ? .node(elements[i]) : nil
		case let .ambiguous(ambiguous): ambiguous.elements.indices.contains(i) ? .node(ambiguous.elements[i]) : nil
		case .attributes, .choice, .value: nil
		}
	}
	
	func container(_ codingKey: any CodingKey) -> _XMLContainer? {
		if let intValue = codingKey.intValue {
			container(at: intValue)
		} else {
			container(named: codingKey.stringValue)
		}
	}
}

@usableFromInline struct _XMLAmbiguousValue {
	let key: String
	let attribute: String
	let elements: [_XMLElement2]
}

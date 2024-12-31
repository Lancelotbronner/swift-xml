//
//  XMLParser.swift
//  swift-xml
//
//  Created by Christophe Bronner on 2024-12-27.
//

import Foundation

struct _XMLElement2 {
	let key: String
	let attributes: [String: String]
	var value = ""
	var children: [_XMLElement2] = []
}

class _XMLStackParser2: NSObject, XMLParserDelegate {
	let decoder: XMLDecoder
	var stack: [_XMLElement2] = []

	init(for decoder: XMLDecoder) {
		self.decoder = decoder
	}

	func parse(with data: Data) throws -> _XMLElement2?  {
		let xmlParser = XMLParser(data: data)
		xmlParser.delegate = self
		xmlParser.shouldProcessNamespaces = false
		xmlParser.shouldReportNamespacePrefixes = false
		xmlParser.shouldResolveExternalEntities = false

		if xmlParser.parse() {
			return stack.isEmpty ? nil : stack.removeLast()
		} else if let error = xmlParser.parserError {
			throw error
		} else {
			return nil
		}
	}

	func parserDidStartDocument(_ parser: XMLParser) {
		stack = []
	}

	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		//TODO: rename according to decoder key convention
		let node = _XMLElement2(key: elementName, attributes: attributeDict)
		stack.append(node)
	}

	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		guard stack.count > 1 else { return }
		let node = stack.removeLast()
		stack[stack.count - 1].children.append(node)
	}

	func parser(_ parser: XMLParser, foundCharacters string: String) {
		guard !stack.isEmpty else { return }
		stack[stack.count - 1].value += string
	}

	func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
		guard !stack.isEmpty, let string = String(data: CDATABlock, encoding: .utf8) else { return }
		stack[stack.count - 1].value += string
	}

	func parser(_ parser: XMLParser, parseErrorOccurred parseError: any Error) {
		print(parseError)
	}
}

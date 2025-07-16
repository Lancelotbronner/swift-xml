# SwiftXML

## Goal

```swift
@XMLCodable
public struct IBDocument {
	@XMLAttribute var type: String?
	@XMLAttribute var version: String?
	@XMLAttribute var toolsVersion: Int?
	@XMLAttribute var targetRuntime: String
	@XMLAttribute var propertyAccessControl: String?
	@XMLAttribute var useAutoLayout: Bool?
	@XMLAttribute var useTraitCollections: Bool?
	@XMLAttribute var useSafeAreas: Bool?
	@XMLAttribute var colorMatched: Bool?
	
	@Element public var dependencies = IBDependencies()
	// directly parses a "customFonts" object
	@Element public var customFonts: IBCustomFonts?
	// parsed within an "objects" element
	@Element public var objects: [IBObject] = []
	// parsed within a "scenes" element
	@Element("scene") public var scenes: [IBScene] = []
	// parses within a "resources" element
	@Element public var resources: [IBResource] = []
}

@XMLCodable
public struct IBCustomFonts {
	@XMLAttribute public var key: String
	@Element("array") public var fonts: [IBFont] = []
}

@XMLCodable
public struct IBFont {
	@XMLAttribute public var key: String
	@Element("string") public var families: [IBFontFamily] = []
}

@XMLCodable
public struct IBFontFamily {
	@Value public var name: String
}

@XMLCodable
public enum IBObject {
	case placeholder(IBPlaceholder)
	case view(IBView)
}

@XMLCodable
public enum IBResource {
	case image(IBImage)
	case systemColor(IBSystemColor)
}

@XMLCodable
public struct IBDependencies {
	@Element var deployments: [IBDeployment]
	@Element var plugins: [IBPlugin]
}

@XMLCodable
public struct IBDeployment: CustomStringConvertible {
	@XMLAttribute var identifier: String
	
	public var description: String {
		"deployment \(identifier)"
	}
}

@XMLCodable
public struct IBPlugin: CustomStringConvertible {
	@XMLAttribute var identifier: String
	@XMLAttribute var version: Int
	
	public var description: String {
		"\(identifier) v\(version)"
	}
}
```

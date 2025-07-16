# SwiftXML

## Goal

```swift
@XMLCodable
public struct IBDocument {
	@Attribute var type: String?
	@Attribute var version: String?
	@Attribute var toolsVersion: Int?
	@Attribute var targetRuntime: String
	@Attribute var propertyAccessControl: String?
	@Attribute var useAutoLayout: Bool?
	@Attribute var useTraitCollections: Bool?
	@Attribute var useSafeAreas: Bool?
	@Attribute var colorMatched: Bool?
	
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
	@Attribute public var key: String
	@Element("array") public var fonts: [IBFont] = []
}

@XMLCodable
public struct IBFont {
	@Attribute public var key: String
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
	@Attribute var identifier: String
	
	public var description: String {
		"deployment \(identifier)"
	}
}

@XMLCodable
public struct IBPlugin: CustomStringConvertible {
	@Attribute var identifier: String
	@Attribute var version: Int
	
	public var description: String {
		"\(identifier) v\(version)"
	}
}
```

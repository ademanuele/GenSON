public enum GenSONError: Error {
    case unsupportedType(name: String, path: [CodingKey])
    case cannotMakeString(message: String)
}

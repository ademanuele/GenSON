import Foundation

protocol JSONKeyedDataContainer {
    var data: [String: Any] { get }
}

protocol JSONUnkeyedDataContainer {
    var data: [Any] { get }
}

protocol JSONSingleValueDataContainer {
    var value: Any? { get }
}

class DummyDecoder<TDecodable: Decodable>: Decoder {

    var data: Any {
        return createdKeyedContainer?.data ??
        createdUnkeyedContainer?.data ??
        createdSingleValueContainer?.value ??
        [:]
    }
    
    private let options: GenSONOptions<TDecodable>

    let userInfo: [CodingUserInfoKey : Any] = [:]
    let codingPath: [CodingKey]
    
    private var createdKeyedContainer: JSONKeyedDataContainer?
    private var createdUnkeyedContainer: JSONUnkeyedDataContainer?
    private var createdSingleValueContainer: JSONSingleValueDataContainer?

    init(using options: GenSONOptions<TDecodable>,
         codingPath: [CodingKey] = []) {
        self.options = options
        self.codingPath = codingPath
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let decoding = DummyKeyedDecoding<Key, TDecodable>(using: options,
                                                           codingPath: codingPath)
        createdKeyedContainer = decoding
        return KeyedDecodingContainer(decoding)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        let decoding = DummyUnkeyedDecoding(using: options, codingPath: codingPath)
        createdUnkeyedContainer = decoding
        return decoding
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        let decoding = DummySingleValueEncoding(using: options, codingPath: codingPath)
        createdSingleValueContainer = decoding
        return decoding
    }
}

fileprivate class DummyKeyedDecoding<Key: CodingKey, TDecodable: Decodable>: KeyedDecodingContainerProtocol, JSONKeyedDataContainer {
    let allKeys: [Key] = []
    let codingPath: [CodingKey]
    
    var data: [String: Any] {
        var d = innerData
        for (k, v) in nestedKeyedContainers { d[k] = v.data }
        for (k, v) in nestedUnkeyedContainers { d[k] = v.data }
        return d
    }
    
    private(set) var innerData: [String: Any] = [:]
    private var nestedKeyedContainers: [String: JSONKeyedDataContainer] = [:]
    private var nestedUnkeyedContainers: [String: JSONUnkeyedDataContainer] = [:]
    
    private let options: GenSONOptions<TDecodable>

    init(using options: GenSONOptions<TDecodable>,
         codingPath: [CodingKey] = []) {
        self.options = options
        self.codingPath = codingPath
    }

    func contains(_ key: Key) -> Bool { true }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let decoding = DummyKeyedDecoding<NestedKey, TDecodable>(using: options,
                                                                 codingPath: codingPath + [key])
        nestedKeyedContainers[key.stringValue] = decoding
        return KeyedDecodingContainer(decoding)
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> any UnkeyedDecodingContainer {
        let decoding = DummyUnkeyedDecoding(using: options, codingPath: codingPath + [key])
        nestedUnkeyedContainers[key.stringValue] = decoding
        return decoding
    }

    func superDecoder() throws -> any Decoder {
        let superKey = Key(stringValue: "super")!
        return try superDecoder(forKey: superKey)
    }

    func superDecoder(forKey key: Key) throws -> any Decoder {
        return DummyDecoder(using: options, codingPath: codingPath + [key])
    }

    // MARK: Decoding

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        if type == Date.self {
            innerData[key.stringValue] = JSONValueFactory.dateValue(using: options)
            return Date() as! T
        }
        
        let decoder = DummyDecoder(using: options,
                                   codingPath: codingPath + [key])
        let decoded = try T(from: decoder)
        innerData[key.stringValue] = decoder.data
        return decoded
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        return false
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        innerData[key.stringValue] = JSONValueFactory.boolValue(using: options)
        return true
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        innerData[key.stringValue] = JSONValueFactory.intValue(using: options)
        return 0
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        innerData[key.stringValue] = JSONValueFactory.doubleValue(using: options)
        return 0.0
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        innerData[key.stringValue] = JSONValueFactory.doubleValue(using: options)
        return 0.0
    }

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        innerData[key.stringValue] = JSONValueFactory.stringValue(using: options)
        return ""
    }

    // MARK: Optionals
    func decodeIfPresent(_ type: Int.Type, forKey key: Key) throws -> Int? {
        guard options.generateOptionals else { return nil }
        return try decode(type, forKey: key)
    }
    
    func decodeIfPresent(_ type: Bool.Type, forKey key: Key) throws -> Bool? {
        guard options.generateOptionals else { return nil }
        return try decode(type, forKey: key)
    }
    
    func decodeIfPresent(_ type: String.Type, forKey key: Key) throws -> String? {
        guard options.generateOptionals else { return nil }
        return try decode(type, forKey: key)
    }
    
    func decodeIfPresent(_ type: Double.Type, forKey key: Key) throws -> Double? {
        guard options.generateOptionals else { return nil }
        return try decode(type, forKey: key)
    }
    
    func decodeIfPresent(_ type: Float.Type, forKey key: Key) throws -> Float? {
        guard options.generateOptionals else { return nil }
        return try decode(type, forKey: key)
    }
    
    func decodeIfPresent<T>(_ type: T.Type, forKey key: Key) throws -> T? where T : Decodable {
        guard options.generateOptionals else { return nil }
        return try decode(type, forKey: key)
    }
}

fileprivate class DummyUnkeyedDecoding<TDecodable: Decodable>: UnkeyedDecodingContainer, JSONUnkeyedDataContainer {
    let options: GenSONOptions<TDecodable>
    let codingPath: [CodingKey]

    var count: Int?
    var isAtEnd: Bool = false
    var currentIndex: Int = 0
    
    var data: [Any] = []

    init(using options: GenSONOptions<TDecodable>,
         codingPath: [CodingKey]) {
        self.options = options
        self.codingPath = codingPath
        count = options.arrayGenerationCount
    }
    
    private func increment() {
        currentIndex += 1
        if currentIndex >= count ?? 0 {
            isAtEnd = true
        }
    }

    private func nextIndexedKey() -> CodingKey {
        return IndexedCodingKey(intValue: currentIndex)!
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        return KeyedDecodingContainer(DummyKeyedDecoding<NestedKey, TDecodable>(
            using: options,
            codingPath: codingPath + [nextIndexedKey()]
        ))
    }

    func nestedUnkeyedContainer() throws -> any UnkeyedDecodingContainer {
        return DummyUnkeyedDecoding(using: options,
                                    codingPath: codingPath + [nextIndexedKey()])
    }

    func superDecoder() throws -> any Decoder {
        return DummyDecoder(using: options, codingPath: [nextIndexedKey()])
    }

    private struct IndexedCodingKey: CodingKey {
        let intValue: Int?
        let stringValue: String

        init?(intValue: Int) {
            self.intValue = intValue
            self.stringValue = intValue.description
        }

        init?(stringValue: String) {
            self.intValue = 0
            self.stringValue = stringValue
        }
    }

    // MARK: Decoding

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        increment()
        let decoder = DummyDecoder(using: options,
                                   codingPath: codingPath + [nextIndexedKey()])
        let t = try T(from: decoder)
        data.append(decoder.data)
        return t
    }

    func decodeNil() throws -> Bool {
        increment()
        return false
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        data.append(JSONValueFactory.boolValue(using: options))
        increment()
        return true
    }

    func decode(_ type: Int.Type) throws -> Int {
        data.append(JSONValueFactory.intValue(using: options))
        increment()
        return 0
    }

    func decode(_ type: Float.Type) throws -> Float {
        data.append(JSONValueFactory.doubleValue(using: options))
        increment()
        return 0.0
    }

    func decode(_ type: Double.Type) throws -> Double {
        data.append(JSONValueFactory.doubleValue(using: options))
        increment()
        return 0.0
    }

    func decode(_ type: String.Type) throws -> String {
        data.append(JSONValueFactory.stringValue(using: options))
        increment()
        return ""
    }

    // MARK: Optionals

    func decodeIfPresent<T>(_ type: T.Type) throws -> T? where T: Decodable {
        increment()
        guard options.generateOptionals else { return nil }
        return try decode(type)
    }
    
    func decodeIfPresent(_ type: Bool.Type) throws -> Bool? {
        increment()
        guard options.generateOptionals else { return nil }
        return try decode(type)
    }
    
    func decodeIfPresent(_ type: String.Type) throws -> String? {
        increment()
        guard options.generateOptionals else { return nil }
        return try decode(type)
    }
    
    func decodeIfPresent(_ type: Double.Type) throws -> Double? {
        increment()
        guard options.generateOptionals else { return nil }
        return try decode(type)
    }
    
    func decodeIfPresent(_ type: Float.Type) throws -> Float? {
        increment()
        guard options.generateOptionals else { return nil }
        return try decode(type)
    }
    
    func decodeIfPresent(_ type: Int.Type) throws -> Int? {
        increment()
        guard options.generateOptionals else { return nil }
        return try decode(type)
    }
}

fileprivate class DummySingleValueEncoding<TDecodable: Decodable>: SingleValueDecodingContainer, JSONSingleValueDataContainer {
    let options: GenSONOptions<TDecodable>
    let codingPath: [CodingKey]
    
    var value: Any?

    init(using options: GenSONOptions<TDecodable>,
         codingPath: [CodingKey]) {
        self.options = options
        self.codingPath = codingPath
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        throw GenSONError.unsupportedType(name: String(describing: T.self),
                                          path: codingPath)
    }

    func decodeNil() -> Bool {
        return false
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        value = JSONValueFactory.boolValue(using: options)
        return true
    }

    func decode(_ type: Int.Type) throws -> Int {
        value = JSONValueFactory.intValue(using: options)
        return 0
    }

    func decode(_ type: Float.Type) throws -> Float {
        value = JSONValueFactory.doubleValue(using: options)
        return 0.0
    }

    func decode(_ type: Double.Type) throws -> Double {
        value = JSONValueFactory.doubleValue(using: options)
        return 0.0
    }

    func decode(_ type: String.Type) throws -> String {
        value = JSONValueFactory.stringValue(using: options)
        return ""
    }
}

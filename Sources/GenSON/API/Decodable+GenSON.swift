import Foundation

public extension Decodable {
    static func generate(options: GenSONOptions<Self> = .init()) throws -> String {
        let data: Data = try generate(options: options)
        guard let s = String(data: data, encoding: .utf8) else {
            throw GenSONError.cannotMakeString(message: "Could not convert generated dummy JSON data into a String.")
        }
        
        return s
    }
    
    static func generate(options: GenSONOptions<Self> = .init()) throws -> Data {
        let dummyDecoder = DummyDecoder(using: options)
        _ = try Self(from: dummyDecoder)
        let jsonData = dummyDecoder.data
        return try JSONSerialization.data(withJSONObject: jsonData,
                                          options: [.sortedKeys, .prettyPrinted])
    }
}

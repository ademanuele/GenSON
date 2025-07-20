import Foundation
import Testing
@testable import GenSON

struct GeneralGenerationTests {
    @Test("Should be able to decode, Given generated JSON")
    func testEncodingDecoding() throws {
        let _ = try generate()
    }
    
    @Test("Should generate arrays correctly, Given number of arrays specified")
    func testArrayGeneration() throws {
        let s: String = try SomeDecodable.generate(options: .init(arrayGenerationCount: 5))
        let generated = try generate(options: .init(arrayGenerationCount: 5))
        
        #expect(generated.innerArray.count == 5)
        #expect(generated.stringArray.count == 5)
        #expect(generated.boolArray.count == 5)
    }
    
    @Test("Should generate optionals as value, Given option")
    func testOptionalGeneration() throws {
        let generated = try generate(options: .init(generateOptionals: true))
        
        #expect(generated.optional != nil)
    }
    
    @Test("Should generate optionals as nil, Given option")
    func testOptionalGenerationOption() throws {
        let generated = try generate(options: .init(generateOptionals: false))
        
        #expect(generated.optional == nil)
    }
    
    @Test("Should generate strings within length, Given option")
    func testStringGeneration() throws {
        let generated = try generate(options: .init(stringLength: 5...5))
        
        #expect(generated.prop.count == 5)
        for s in generated.stringArray {
            #expect(s.count == 5)
        }
    }
    
    @Test("Should generate date correctly, Given format")
    func testDateGeneration() throws {
        let generated: Data = try SimpleDateDecodable.generate(options: .init(dateFormat: "yyyy"))
        let jsonData = try JSONSerialization.jsonObject(with: generated) as? [String: Any]
        let dateString = jsonData?["date"] as? String
        let year = Int(dateString ?? "")
        #expect(year ?? 0 >= 2025)
    }
    
    func generate(options: GenSONOptions<SomeDecodable> = .init()) throws -> SomeDecodable {
        let generatedJSON: String = try SomeDecodable.generate(options: options)
        let generatedData = generatedJSON.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SomeDecodable.self, from: generatedData)
    }
}

struct SomeDecodable: Decodable {
    let prop: String
    let someOtherProp: Int
    let optional: Int?
    let someDouble: Double
    let someDate: Date
    let inner: InnerConfig
    let innerArray: [InnerConfig]
    let stringArray: [String]
    let boolArray: [Bool]
//    let someEnum: SomeEnumDecodable

    struct InnerConfig: Decodable {
        let innerProp: String
        let innerPropAgain: Int
    }
    
    enum SomeEnumDecodable: String, Decodable {
        case valueA
        case valueB
    }
}

struct SimpleDateDecodable: Decodable {
    let date: Date
}

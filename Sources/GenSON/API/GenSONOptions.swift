import Foundation

public struct GenSONOptions<TDecodable: Decodable> {
    public let arrayGenerationCount: Int
    public let stringLength: ClosedRange<Int>
    public let intRange: ClosedRange<Int>
    public let dateFormat: String?
    public let generateOptionals: Bool

    public init(
        arrayGenerationCount: Int = 5,
        stringLength: ClosedRange<Int> = 5...200,
        intRange: ClosedRange<Int> = 5...2000,
        dateFormat: String? = nil,
        generateOptionals: Bool = true
    ) {
        self.arrayGenerationCount = arrayGenerationCount
        self.stringLength = stringLength
        self.intRange = intRange
        self.dateFormat = dateFormat
        self.generateOptionals = generateOptionals
    }
}

import Foundation

struct JSONValueFactory {
    static func stringValue<TDecodable>(using options: GenSONOptions<TDecodable>) -> String {
        let length = Int.random(in: options.stringLength)
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    static func doubleValue<TDecodable>(using options: GenSONOptions<TDecodable>) -> Double {
        return .random(in: Double(options.intRange.lowerBound)...Double(options.intRange.upperBound))
    }
    
    static func intValue<TDecodable>(using options: GenSONOptions<TDecodable>) -> Int {
        return .random(in: options.intRange)
    }
    
    static func boolValue<TDecodable>(using options: GenSONOptions<TDecodable>) -> Bool {
        return true
    }
    
    static func dateValue<TDecodable>(using options: GenSONOptions<TDecodable>) -> String {
        if let dateFormat = options.dateFormat {
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            return formatter.string(from: Date())
        }
        
        return ISO8601DateFormatter().string(from: Date())
    }
}

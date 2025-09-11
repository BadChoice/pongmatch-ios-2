import Foundation

extension Encodable {
    func jsonString() throws  -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(self)
        return String(data: jsonData, encoding: .utf8) ?? "** NO JSON **"
    }
}

import Foundation

let dateFormatter = DateFormatter()
for _ in 0..<1_000_000 {
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    _ = dateFormatter.string(from: Date())
}

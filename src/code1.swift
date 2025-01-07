import Foundation

for _ in 0..<1_000_000 {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    _ = dateFormatter.string(from: Date())
}

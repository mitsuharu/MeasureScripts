import Foundation

/*

最適化なし
swiftc -Onone code.swift -o code

最適化
swiftc -O code.swift -o code

*/

for _ in 0..<1_000_000 {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    _ = dateFormatter.string(from: Date())
}

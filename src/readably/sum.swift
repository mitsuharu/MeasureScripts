import Foundation

do {
    let data = [1, 2, 3, 4, 5]
    var result = 0
    for i in 0..<data.count {
        result &+= data[i]  // &+ はオーバーフローを防ぐための演算子
    }
    print(result)
}

do {
    let data = [1, 2, 3, 4, 5]
    let result = data.reduce(0, +)
    print(result)
}

do {
    let data = [1, 2, 3, 4, 5, Int.max]
    var result = 0
    for i in 0..<data.count {
        result &+= data[i]  // &+ はオーバーフローを防ぐための演算子
    }
    print(result)
}

do {
    let data = [1, 2, 3, 4, 5, Int.max]
    let result = data.reduce(0, +)
    print(result)
}

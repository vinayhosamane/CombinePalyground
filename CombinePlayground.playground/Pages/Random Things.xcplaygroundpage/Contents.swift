//: [Previous](@previous)

import Foundation

var closureArray:[() -> ()] = []

var i = 0

for _ in 1...5 {
    closureArray.append { [i] in
        print(i)
    }
    i += 1
}

closureArray[0]()
closureArray[3]()

//: [Next](@next)

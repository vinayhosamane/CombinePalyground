//: [Previous](@previous)

import Foundation

// Property wrappers use cases

// property wrappers can only be applied to vars, if you declare on let, it throws compile time error
@propertyWrapper
struct Capitalized {
    // stored property didSet won't get called untill the modification..not even on initialiser
    var wrappedValue: String {
        didSet {
            wrappedValue = wrappedValue.capitalized
        }
    }
    
    init(wrappedValue: String) {
        self.wrappedValue = wrappedValue.capitalized
    }
}

struct Output {
    @Capitalized var someString: String
}

let output = Output(someString: "vinay hosamane")
print(output.someString)

//: [Next](@next)

//: [Previous](@previous)

import Foundation
import Combine

var cancellables = Set<AnyCancellable>()

enum SomeError: Error {
    case Unknown
}

let publisher = Just("Vinay Hosamane")

publisher
    .map({ (value) in
        Fail(outputType: SomeError.self, failure: SomeError.Unknown)
    })
    .retry(2)
    .sink { (completion) in
        switch completion {
        case .failure(let error):
            print(error)
        default:
            print("Finished")
        }
    } receiveValue: { (someError) in
        if case .Unknown = someError.error {
            print("Received unknown error")
        }
    }.store(in: &cancellables)


// map
// tryMap
// compactMap
// switchToLatest


//: [Next](@next)

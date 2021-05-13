//: [Previous](@previous)

import Foundation
import Combine

class SomeSubject {
    var someSubjectPublisher: AnyPublisher<Int, Never> {
        passthroughSubject.eraseToAnyPublisher()
    }
    
    var currentValueSubjectPublisher: AnyPublisher<Int, Never> {
        currentValueSubject.eraseToAnyPublisher()
    }
    
    init() {
    }
    
    private let passthroughSubject = PassthroughSubject<Int, Never>()
    
    private let currentValueSubject = CurrentValueSubject<Int, Never>(100)
    
    func fetch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.passthroughSubject.send(10)
        }
    }
}

var cancellables = [AnyCancellable]()

let subject = SomeSubject()
subject.someSubjectPublisher.sink { (someValue) in
    print("Inside Passthrough Subject Subscriber ---- \(someValue)")
}.store(in: &cancellables)

subject.currentValueSubjectPublisher.sink { (currentValue) in
    print("Inside Current Value Subscriber --- \(currentValue)")
}.store(in: &cancellables)

subject.fetch()

//: [Next](@next)

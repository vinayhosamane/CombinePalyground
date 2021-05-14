//: [Previous](@previous)

import Foundation
import Combine

class SomeSubject {
    var someSubjectPublisher: AnyPublisher<Int, Never> {
        passthroughSubject.eraseToAnyPublisher()
    } // abstracting subjects and converting them to AnyPublisher.
    
    var currentValueSubjectPublisher: AnyPublisher<Int, Never> {
        currentValueSubject.eraseToAnyPublisher()
    }
    
    init() {
    }
    
    private let passthroughSubject = PassthroughSubject<Int, Never>() // starts with no value
    
    private let currentValueSubject = CurrentValueSubject<Int, Never>(100) // used when we want to start with default or current value.
    
    func fetch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.passthroughSubject.send(10)
            
            let subscription = Subscriptions.empty
            
            self?.passthroughSubject.send(subscription: subscription)
            
            self?.passthroughSubject.send(completion: Subscribers.Completion<Never>.finished)
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

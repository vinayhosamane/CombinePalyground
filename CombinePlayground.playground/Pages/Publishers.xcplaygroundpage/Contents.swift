//: [Previous](@previous)

import Foundation
import Combine

class CombinePlayground  {
    
    @Published private(set) var items = [Int]()

    init() {}
    
    func execute() -> AnyPublisher<Int, Never> {
        //let publisher = [1, 2, 3].publisher.eraseToAnyPublisher()
        
//        publisher.sink { (ele) in
//            print(ele)
//        }.store(in: &cancellables)
        
        return Deferred {
            [1, 2, 3].publisher.eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
    
    func updateItem(_ item: Int) {
        items.append(item)
    }

}

var cancellables = [AnyCancellable]()

let combinePlayground = CombinePlayground()

combinePlayground.execute().sink { (_) in
    //handle completion here
} receiveValue: { (element) in
    print(element)
}.store(in: &cancellables)

combinePlayground
    .$items
    .assertNoFailure()
    .breakpoint()
    .handleEvents { _ in
        print("Receievd subscription")
    } receiveOutput: { (output) in
        print("Received Output ---- \(output)")
    } receiveCompletion: { (completion) in
        switch completion {
        case .finished:
            print("Finished !!")
        default:
            print("Inside Default switch case")
        }
    } receiveCancel: {
        print("Received Cancel on subscription")
    } receiveRequest: { (demand) in
        print("Received demand")
    }.sink { (result) in
        print(result)
    }.store(in: &cancellables)


combinePlayground.updateItem(10)

Just(200)
    .append(Empty(completeImmediately: false))
    .sink { (_) in
        print("Inside Completion")
    } receiveValue: { (someValue) in
        print("Inside Recieve Value")
    }.store(in: &cancellables)

enum ErrorType: Error {
    case Unknown
}

Fail<Never, ErrorType>(error: ErrorType.Unknown).sink { (completion) in
    if case .failure(let error) = completion {
        print(error)
    }
} receiveValue: { _ in }

//: [Next](@next)

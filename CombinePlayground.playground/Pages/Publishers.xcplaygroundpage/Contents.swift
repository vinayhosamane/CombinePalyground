//: [Previous](@previous)

import Foundation
import Combine

class CombinePlayground  {
    
    @Published private(set) var items = [Int]() // property warapper Published, creates a publisher.

    init() {}
    
    func execute() -> AnyPublisher<Int, Never> {
        //let publisher = [1, 2, 3].publisher.eraseToAnyPublisher()
        
//        publisher.sink { (ele) in
//            print(ele)
//        }.store(in: &cancellables) // this publisher sends value change immidetely without waiting for subscription.
        
        return Deferred {
            [1, 2, 3].publisher.eraseToAnyPublisher()
        }.eraseToAnyPublisher() // Defferred sends value only after it received subscription.
    }
    
    func updateItem(_ item: Int) {
        items.append(item)
    }

}

var cancellables = [AnyCancellable]() // we can store all disposable subscriptions here.

let combinePlayground = CombinePlayground()

combinePlayground.execute().sink { (_) in
    //handle completion here
} receiveValue: { (element) in
    print(element)
}.store(in: &cancellables) // observed, without storing the subscription in cancellable array, it won't subscribe to value change.

combinePlayground
    .$items
    .assertNoFailure() // checks there are no error data received from upstream publisher.
    .breakpoint() // supposed break here, and open in debugger.
    .handleEvents { _ in // called when it received any events, here we can do any other side effect code execution. ex. caching
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
    }.sink { (result) in // sink, default or already available subscriber.
        print(result)
    }.store(in: &cancellables)


combinePlayground.updateItem(10)

Just(200) // Publisher sends only one value and never emits error. received value -- recieve completion
    .append(Empty(completeImmediately: false)) // appending another publisher -- receive value, won't complete
    .sink { _ in
        print("Inside Completion")
    } receiveValue: { (someValue) in
        print("Inside Recieve Value")
    }.store(in: &cancellables)

enum ErrorType: Error {
    case Unknown
}

// another publisher type fail, only returns failure downstream.
Fail<Never, ErrorType>(error: ErrorType.Unknown).sink { (completion) in
    if case .failure(let error) = completion {
        print(error)
    }
} receiveValue: { _ in }


// ObservableObject
class ObservableObjectPublisher: ObservableObject {
//    var someValue = 0 {
//        willSet {
//            objectWillChange.send()
//        }
//    } // this is used in SwiftUI view content bindings. @ObservableObject property warpper will be used.
    // @Published, emits all changes automatically. To control that we can use objectWillChange.send() on accessors.
    @Published var someValue = 0
}

let observableObject = ObservableObjectPublisher()
observableObject.$someValue.sink { (someValue) in
    print(someValue)
}

observableObject.someValue = 10

observableObject.objectWillChange.makeConnectable().autoconnect().sink { (someValue) in
    print("Inside object will change subscriber: \(someValue)")
}

observableObject.someValue = 100


enum NetworkError: Error {
    case Unkown
    case SessionTimedOut
    case InvalidRequest
}

struct Post: Codable {
    var userId: Int
    var id: Int
    var title: String
    var body: String
}

// usage of url session with combine
class NetworkManager {
    func fetchPosts(url: URL) -> AnyPublisher<[Post], Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap({ (output) in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw NetworkError.Unkown
                }
                return output.data
            })
            .decode(type: [Post].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()

    }
}

//let networkManager = NetworkManager()

//if let url = URL(string: "https://jsonplaceholder.typicode.com/posts") {
//    networkManager.fetchPosts(url: url).sink { (completion) in
//        switch completion {
//        case .failure(let error):
//            print("Network failure. -- \(error)")
//        case .finished:
//            print("Publisher completed.")
//        }
//    } receiveValue: { (posts) in
//        print(posts)
//    }.store(in: &cancellables)
//}

class SomeViewModel {
    private var posts: [Post] = [] {
        didSet {
            print("posts ---> \(self.posts)")
        }
    }
    
    var someInt: Int = 0 {
        didSet {
            print(someInt)
        }
    }
    
    let networkManager: NetworkManager
    
    var cancellables = [AnyCancellable]()
    
    init(networkManager manager: NetworkManager) {
        networkManager = manager
    }
    
    func fetchPosts() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            return
        }
        networkManager.fetchPosts(url: url).sink { (completion) in
            switch completion {
            case .failure(let error):
                print("Network request failed with error: \(error)")
            default:
                print("Network request finished.")
            }
        } receiveValue: { [weak self] (posts) in
            self?.posts = posts
        }.store(in: &cancellables)
    }
}

let someViewModel = SomeViewModel(networkManager: NetworkManager())
someViewModel.fetchPosts()

[1, 2, 3].publisher.assign(to: \.someInt, on: someViewModel)

//: [Next](@next)

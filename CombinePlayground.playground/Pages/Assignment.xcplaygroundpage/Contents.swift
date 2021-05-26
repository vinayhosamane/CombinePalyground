//: [Previous](@previous)

import Foundation
import Combine

// Catalog List Screen
     // Search Bar
     // List (Dynamic Content)
         // affecting constraints
              // pull to refresh
              // applyin filter
              // search query

// Catalog Services
    // responsible for fetching catalog data
        // Publishers
/*
   Class CatalogServices {
 // one api
    func fetchCatalogCards() -> AnyPublisher<Output, Failure> {
        return Publisher {
            // QueryManager
        }
     }
 }
 */

/*
  class CatalogListViewModel {
      <Publisher> var presentableModels: [Model] = []
      
 
       func fetchCards() {
           // use catalog service publisher and get data
           // view model is the subscriber
 
           // update presentableModel
       }
 }
 */

struct CatalogCard {
    let name: String
}

enum CatalogServceFailure: Error {
    case httpError
    case orcaError
    case unknown
}

protocol CatalogServicesProtocol {
    func fetchCatalogCards() -> AnyPublisher<[CatalogCard], CatalogServceFailure>?
}

final class CatalogService: CatalogServicesProtocol {
    
    func fetchCatalogCards() -> AnyPublisher<[CatalogCard], CatalogServceFailure>? {
        return Future<[CatalogCard], CatalogServceFailure> { (promise) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                // generate the model
                let oneCard = CatalogCard(name: "SAP Sales")
                promise(.success([oneCard]))
            }
        }.eraseToAnyPublisher()
    }

}

class CatalogListViewModel {
    
    @Published private(set) var _model: [CatalogCard] = []
    
    var modelPublisher: AnyPublisher<[CatalogCard], Never> {
       $_model.eraseToAnyPublisher()
    }
    
    //@Published private(set) var _filteredModels: [CatalogCard] = []
    
    // @published
    // Subjects
    // AnyPublisher
    
    private var catalogServiceManager: CatalogServicesProtocol
    
    private var subscribers = [AnyCancellable]()
    
    let modelUpdateSubject = CurrentValueSubject<[CatalogCard], Never>([])
    
    // dependency injection
    init(_ catalogService: CatalogServicesProtocol) {
        catalogServiceManager = catalogService
        
        // let's dispatch call to get catalog cards from service
        catalogServiceManager
            .fetchCatalogCards()?
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    print("Done fetching cards")
                case .failure(let error):
                    print(error)
                }
            }, receiveValue: { [weak self] (cards) in
                self?._model.append(contentsOf: cards)
                
                // send a pulish event
                //self?.modelUpdateSubject.send(cards)
//                self?.modelUpdateSubject.send(completion: Subscribers.Completion<Never>.finished)
            }).store(in: &subscribers)
    }
    
    func updateModel(with cards: [CatalogCard]) {
        _model.append(contentsOf: cards)
    }

}

// testing
var subscribers = [AnyCancellable]()

let networkManager = CatalogService()
let viewModel = CatalogListViewModel(networkManager)

let modelUpdatePlublisher = viewModel.$_model.eraseToAnyPublisher()

modelUpdatePlublisher.sink { (cards) in
    print(cards)
}.store(in: &subscribers)

viewModel.updateModel(with: [CatalogCard(name: "Vinay"),
                             CatalogCard(name: "Ramya"),
                             CatalogCard(name: "Sindhu")])

//: [Next](@next)

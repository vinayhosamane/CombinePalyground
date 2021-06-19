//: [Previous](@previous)

import Foundation
import Combine

// Catalog list
     // Serach Bar -- a, ab, abc, abcd..
     // Filter -- All, Published, Favorite   -- applied filter is 'Favorite'

// search api
    // search query  --- publisher
    // applied filter  --- publisher

// search -- optimisation
    // debounce
    // usage -- 2

enum Filters {
    case All
    case Favorites
    case Published
}

// filter publihser
class FilterModel {
    @Published var currentAppliedFilter: Filters = Filters.All
    
    func applyFilter(filter currentFilter: Filters) {
        currentAppliedFilter = currentFilter
    }
}

// list search manager
class SearchManager {
    @Published var searchQuery: String = ""
    
    func applySearchQuery(_ searchQuery: String) {
        self.searchQuery = searchQuery
    }
}

// dispose bag
var subscriptions = [AnyCancellable]()

let filterModel = FilterModel()
let searchManager = SearchManager()

let filterPublisher = filterModel.$currentAppliedFilter.eraseToAnyPublisher()
let searchQueryPublisher = searchManager.$searchQuery.eraseToAnyPublisher()

// a           ab          bc         abcd       abcde
// All   Favorite
// (abcde, Favorite)

searchQueryPublisher
    .combineLatest(filterPublisher)
    .debounce(for: .seconds(2), scheduler: DispatchQueue.global())
    .receive(on: DispatchQueue.main)
    .sink { (searchQuery, currentAppliedFilter) in
        print("Combined publishers --- search bar text : \(searchQuery) -- current filter: \(currentAppliedFilter)")
    }
    .store(in: &subscriptions)

// let's publish
filterModel.applyFilter(filter: .Favorites)
filterModel.applyFilter(filter: .Published)

searchManager.applySearchQuery("a")
searchManager.applySearchQuery("ab")
searchManager.applySearchQuery("abc")


class SomeViewModel {
    var updateClosure: (() -> Void)? = { }
    
    var model: String = "" {
        didSet {
            updateClosure?()
        }
    }
    
    init(closure block: (() -> Void)? = nil) {
        updateClosure = block ?? nil
    }
    
    func updateModel(_ string: String) {
        model = string
    }
}

let someViewModel = SomeViewModel()

// view controller -- viewmodel
someViewModel.updateClosure = {
    print("updated")
}

someViewModel.updateModel("Vinay")


struct Constants {
    static var someValue: Any? = "true"
}

func getConstant() -> Bool {
    guard let constant = Constants.someValue as? String,
          let constantBool = Bool(constant) else {
        return false
    }
    return constantBool
}



//: [Next](@next)

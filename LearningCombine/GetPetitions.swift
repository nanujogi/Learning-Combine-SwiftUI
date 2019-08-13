//  GetPetitions.swift
//  LearningCombine
//  Created by Nanu Jogi on 03/07/19.
//  Copyright © 2019 Greenleaf Software. All rights reserved.

import SwiftUI
import Combine

class GetPetitions: ObservableObject {
    
    typealias PublisherType = PassthroughSubject<Void, Never>
    
    let url = "https://api.whitehouse.gov/v1/petitions.json?limit=15"
    
    // models is an array of Petition
    @Published var models: [Petition] = []
    
    // fetch func will be used in .onAppear inside ContentView.swift
    func fetch() {
        if let url = URL(string: url) {
            
            // Create an URLSession.shared.dataTaskPublisher.
            let remoteDataPublisher = URLSession.shared.dataTaskPublisher(for: url)
                // the dataTaskPublisher output combination is (data: Data, response: URLResponse)
                
                // using different operators map, decode
                //               .map {$0.data}
                .map({ (inputTuple) -> Data in
                    return inputTuple.data
                })
                .decode(type: Petitions.self, decoder: JSONDecoder())
                .map{$0.results}
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()  // cleans up the type signature of the property
            
            // Complete sink has two closures
            let _ = remoteDataPublisher
                .sink(receiveCompletion: { fini in
                    switch fini {
                    case .finished :
                        print(".sink() receiveCompletion", String(describing: fini))
                    case .failure:
                        print("Error in receiveCompletion")
                    }
                }, receiveValue: { someValue in
                    self.models = someValue // save it in our models.
                    //print(".sink() receiveValue \(someValue)\n")
                })
        }
    }
} // end of class GetPetitions

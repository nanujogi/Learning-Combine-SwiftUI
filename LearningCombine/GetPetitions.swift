//  GetPetitions.swift
//  LearningCombine
//  Created by Nanu Jogi on 03/07/19.
//  Copyright © 2019 Greenleaf Software. All rights reserved.

import Foundation
import UIKit
import SwiftUI
import Combine

class GetPetitions: BindableObject {
    
    let url = "https://api.whitehouse.gov/v1/petitions.json?limit=15"
    
    var didChange = PassthroughSubject<Void, Never>()
    // PassthroughSubject does not maintain any state, just passes through provided values.
    
    // models is an array of Petition
    var models: [Petition] = [] {
        didSet {
            DispatchQueue.main.async {
                self.didChange.send(()) // this send() call will send values to subscribers.
            }
        }
    }
    
    // fetch func will be used in .onAppear inside ContentView.swift
    func fetch() {
        if let url = URL(string: url) {
            
            // Create an URLSession.shared.dataTaskPublisher.
            let remoteDataPublisher = URLSession.shared.dataTaskPublisher(for: url)
                // the dataTaskPublisher output combination is (data: Data, response: URLResponse)
                
                // using different operators map, decode
                .map({ (inputTuple) -> Data in
                    return inputTuple.data
                })
                
                .decode(type: Petitions.self, decoder: JSONDecoder())
                
                // cleans up the type signature of the property
                // getting asigned to the chain of operators
                .eraseToAnyPublisher()
            
            // validate
            let _ = remoteDataPublisher
                
                // Whatever received just run it on Main Thread.
                // If we put it in end after .sink gives error.
                
              //  .receive(on: RunLoop.main)
                // Was giving error because the thread of fetching petition was running in
                // backgroup & now once its completed we want to move it to main thread.
                // So added this operator here.
                
                .sink(receiveCompletion: { fini in
                    print(".sink() receiveCompletion triggers", String(describing: fini))
                    
                }, receiveValue: { someValue in
                    self.models = someValue.results // save it in our models.
                    //                    print(".sink() receiveValue \(someValue)\n")
                })
            
            print(type(of: remoteDataPublisher.self))
            // Result of above print:
            // AnyPublisher<Petitions, Error>
            
            print("Petitions received & Saved in models")
        }
    }
} // end of class GetPetitions

//
//  CombinePattern.swift
//  LearningCombineTests


import Foundation
import XCTest
import Combine

class CombinePattern: XCTestCase {
    var testURL: URL?
    
    enum testFailureCondition: Error {
        case invalidServerResponse
    }
    
    struct Petitions: Codable {
        
        var results: [Petition]
    }
    
    struct Petition: Codable {
        var title: String
        var body: String
        var signatureCount: Int
        var url: String
    }
    
    let testURLString = "https://api.whitehouse.gov/v1/petitions.json?limit=5"
//    let testURLString = "http://ip.jsontest.com"
    
    // matching the data structre return from above site
//    struct IPInfo: Codable {
//        var title: String
//    }
    
    override func setUp() {
        self.testURL = URL(string: testURLString)
    }
    
    func testSimpleURLDecodeChain() {
        // setup
        let expectation = XCTestExpectation(description: "Download from \(String(describing: testURL))")
        let remoteDataPublisher = URLSession.shared.dataTaskPublisher(for: self.testURL!)
            // the dataTaskPublisher output combination is (data: Data, response: URLResponse)
            .map({ (inputTuple) -> Data in
                return inputTuple.data
            })
            .decode(type: Petitions.self, decoder: JSONDecoder())
        
        XCTAssertNotNil(remoteDataPublisher)
        
        // validate
        let _ = remoteDataPublisher
            .sink(receiveCompletion: { fini in
                print(".sink() receiveCompletion: ", String(describing: fini))
                switch fini {
                case .finished: expectation.fulfill()
                case .failure: XCTFail()
                }
            }, receiveValue: { someValue in
                XCTAssertNotNil(someValue)
                print(".sink() receiveValue: \(someValue)\n")
            })
        
        wait(for: [expectation], timeout: 10.0)
        print("TEST COMPLETE")
        
    }
    
}

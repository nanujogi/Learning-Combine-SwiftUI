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
    
    func testSimplePipeline() {
        let _ = Just(5)
        .map{ (value) -> String in
            switch value {
            case _ where value < 1:
                return "none"
            case _ where value == 1:
                return "one"
            case _ where value == 2:
                return "couple"
            case _ where value == 3:
                return "few"
            case _ where value > 8:
                return "many"
            default:
                return "some"
            }
        }
        .sink { (receivedValue) in
            print("The end result was \(receivedValue)")
        }
    }
    
    func testUnderstand() {
        
        enum WeatherError: Error {
            case thingsJustHappen
        }
        
        let weatherPublisher = PassthroughSubject<Int, Error>()
        let subscriber = weatherPublisher
            .filter { $0 > 25 }
            .sink { value in
                print("A summer day of \(value) C")
        }
        
        let anotherSubscriber = weatherPublisher.handleEvents(receiveSubscription: { (subscription) in
            print("New Subscription \(subscription)")
        }, receiveOutput: { (output) in
            print("New Value: Output \(output)")
        }, receiveCompletion: { (error) in
            print("Subscription completed with poetnetion error \(error)")
        }, receiveCancel: {
            print("Subscription cancelled")
        }).sink { (value) in
            print("Subscriber received value: \(value)")
        }
        
        weatherPublisher.send(10)
        weatherPublisher.send(20)
        weatherPublisher.send(24)
        weatherPublisher.send(26)
        weatherPublisher.send(28)
        weatherPublisher.send(30)
        
        weatherPublisher.send(completion:
            Subscribers.Completion.failure(WeatherError.thingsJustHappen))
        weatherPublisher.send(18)
    }
}

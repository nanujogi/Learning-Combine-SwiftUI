//
//  CombinePattern.swift
//  LearningCombineTests


import Foundation
import UIKit
import XCTest
import Combine

class CombinePattern: XCTestCase {
    var testURL: URL?
    var glURL: URL?
    
    var myBackgroundQueue: DispatchQueue?
    
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
    let glURLString = "http://www.grenleaf.com/getjson.txt"
    //    let testURLString = "http://ip.jsontest.com"
    
    // matching the data structre return from above site
    //    struct IPInfo: Codable {
    //        var title: String
    //    }
    
    override func setUp() {
        self.testURL = URL(string: testURLString)
        self.myBackgroundQueue = DispatchQueue(label: "combineExamples")

        self.glURL = URL(string: glURLString)
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
            .subscribe(on: self.myBackgroundQueue!)
            .eraseToAnyPublisher()
        
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
            print("💥 receivedValue is \(receivedValue)")
        }
    }
    
        func testUnderstand() {
    
            enum WeatherError: Error {
                case thingsJustHappen
            }
    
            let weatherPublisher = PassthroughSubject<Int, Error>()
            let subscriber = weatherPublisher
                .filter { $0 > 25 }
                //TODO
            
            .sink(receiveCompletion: { fini in
                print(".sink() receiveCompletion: ", String(describing: fini))
            }, receiveValue: { someValue in
                print(".sink() receiveValue: \(someValue)\n")
            })

            let anotherSubscriber = weatherPublisher.handleEvents(receiveSubscription: { (subscription) in
                print("New Subscription \(subscription)")
            }, receiveOutput: { (output) in
                print("New Value: Output \(output)")
            }, receiveCompletion: { (error) in
                print("Subscription completed with poetnetion error \(error)")
            }, receiveCancel: {
                print("Subscription cancelled")
            })
            .sink(receiveCompletion: { fini in
                print("anotherSubscriber .sink() receiveCompletion: ", String(describing: fini))
            }, receiveValue: { someValue in
                print("anotherSubscriber .sink() receiveValue: \(someValue)\n")
            })

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
    
    func testCodes() {
        
        let publisher = Just(28)
        
        // This creates a `Subscriber` on the `Just a 28` Publisher
        publisher
            // We change the value
            .map { number in
                return "Antoine's age is \(number)"
        }
            // We subscribe using `sink`
            
            .sink(receiveCompletion: { fini in
                print("💥 .sink() receiveCompletion: ", String(describing: fini))
            }, receiveValue: { someValue in
                print("💥 .sink() receiveValue: \(someValue)\n")
            })
    }
    
    func testCodes2() {
        
        enum RequestError: Error {
            case sessionError(error: Error)
        }
        
        let URLPublisher = PassthroughSubject<URL, RequestError>()
        URLPublisher.flatMap { requestURL in
            return URLSession.shared.dataTaskPublisher(for: requestURL)
                .mapError { error -> RequestError in
                    return RequestError.sessionError(error: error)
            }
        }
            
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("✅ .sink() received the completion:", String(describing: completion))
                    // no associated data, but you can react to knowing the request has been completed
                    XCTFail("We should never receive the completion, because the cancel should happen first")
                    break
                case .failure(let anError):
                    // do what you want with the error details, presenting, logging, or hiding as appropriate
                    print("❌ received the error: ", anError)
                    XCTFail("We should never receive the completion, because the cancel should happen first")
                    break
                }
            }, receiveValue: { someValue in
                // do what you want with the resulting value passed down
                // be aware that depending on the data type being returned, you may get this closure invoked
                // multiple times.
                XCTAssertNotNil(someValue)
                print("✅ .sink() received \(someValue)")
            })
        
        URLPublisher.send(URL(string: "https://xys.stra")!)
        //        URLPublisher.send(URL(string: "https://httpbin.org/image/jpeg")!)
    }
    
    func testCodes3() {
        struct FormViewModel {
            @Published var isSubmitAllowed: Bool = false
        }
        
        final class FormViewController: UIViewController {
            
            var viewModel = FormViewModel()
            let submitButton = UIButton()
            
            override func viewDidLoad() {
                super.viewDidLoad()
                viewModel.$isSubmitAllowed
                    .receive(on: DispatchQueue.main)
                    .assign(to: \.isEnabled, on: submitButton)
            }
        }
        
        let formViewController = FormViewController(nibName: nil, bundle: nil)
        print("Button enabled is \(formViewController.submitButton.isEnabled)")
        formViewController.viewModel.isSubmitAllowed = true
        print("Button enabled is \(formViewController.submitButton.isEnabled)")
        
    }
    
    //    func testCodes4() {
    //        /*:
    //         [Previous](@previous)
    //         ## Debugging
    //         Operators which help to debug Combine streams and implementations.
    //
    //         More info: [https://www.avanderlee.com/debugging/combine-swift/‎](https://www.avanderlee.com/debugging/combine-swift/‎)
    //         */
    //
    //        enum ExampleError: Swift.Error {
    //            case somethingWentWrong
    //        }
    //
    //        /*:
    //         #### Handling events
    //         Can be used combined with breakpoints for further insights.
    //         */
    //        let subject = PassthroughSubject<String, ExampleError>()
    //        let subscription = subject.handleEvents(receiveSubscription: { (subscription) in
    //            print("Receive subscription")
    //        }, receiveOutput: { output in
    //            print("Received output: \(output)")
    //        }, receiveCompletion: { _ in
    //            print("Receive completion")
    //        }, receiveCancel: {
    //            print("Receive cancel")
    //        }, receiveRequest: { demand in
    //            print("Receive request: \(demand)")
    //        }).sink { _ in }
    //
    //        subject.send("Hello!")
    //        subscription.cancel()
    //
    //        // Prints out:
    //        // Receive request: unlimited
    //        // Receive subscription
    //        // Received output: Hello!
    //        // Receive cancel
    //
    //        //subject.send(completion: .finished)
    //
    //        /*:
    //         #### Print
    //         Using the print operator to log messages for all publishing events.
    //         */
    //
    //        let printSubscription = subject.print("Print example").sink { _ in }
    //
    //        subject.send("Hello!")
    //        printSubscription.cancel()
    //
    //        // Prints out:
    //        // Print example: receive subscription: (PassthroughSubject)
    //        // Print example: request unlimited
    //        // Print example: receive value: (Hello!)
    //        // Print example: receive cancel
    //
    //        //: [Next](@next)
    //
    //    }
    //
    func testArlindCode1() {
        let publisher = Just("Combine Swift")
        let sequencePublisher = Publishers.Sequence<[Int], Never>(sequence: [1,2,3,5,6])
        
        let subscription = publisher.sink { (value) in
            print(value)
        }
        print(type(of: subscription)) // Sink<String, Never>
        print(subscription) //Sink
        
        let subscriber = publisher
            .sink(receiveCompletion: { fini in
                print(".sink() receiveCompletion: ", String(describing: fini))
            }, receiveValue: { someValue in
                print(".sink() receiveValue: \(someValue)")
            })
        print(subscriber) // Sink
        subscriber.cancel()
        // Subscribers can be also canceled at any time in order to avoid
        // receiving events from the publishers by simply calling cancel on them
        
    }
    
    // Subject
    func testArlindCode2() {
        let subject = PassthroughSubject<String,Never>()
        let publisher = subject.eraseToAnyPublisher()
        print(type(of: subject)) // PassthroughSubject<String, Never>
        print(type(of: publisher)) // AnyPublisher<String, Never>
        
        let subscriber1 = publisher.sink { (value) in
            print(value)
        }
        
        // subscriber1 will receive the events but not the subscriber2
        subject.send("Event1")
        subject.send("Event2")
        
        let subscriber2 = publisher.sink { (value) in
            print(value)
        }
        // subscriber1 and subscriber2 will receive this event
        subject.send("Event3")
    }
    // Operators
    func testArlindCode3() {
        _ = Publishers.Sequence<[Int], Never>(sequence: [1,2,4])
            .map{$0 * 10}
            .flatMap { Just($0)}
            .sink(receiveValue: { print ($0) })
        
    }
    // Filtering
    func testArlindCode4() {
        _ = Publishers.Sequence<[Int], Never>(sequence: [1,2,2,3,3,4,7])
            .map {$0 * 2}
            .flatMap{ data -> Just<Int> in
                print("💥 Data's are \(data)")
                //                print(type(of: data)) // Int
                return Just(data)
        }
            // .flatMap {Just($0)}
            .filter { $0.isMultiple(of: 2) }
            .dropFirst(3) // omits the specified number of elements before republishing subsequent elements.
            .removeDuplicates() // publishes only elements that don't match the previous element
            .sink(receiveValue: { (value) in
                print("💥 \(value)")
            })
    }
    // Merge
    func testArlindCode5() {
        let germanCities = PassthroughSubject<String, Never>()
        let italianCities = PassthroughSubject<String, Never>()
        let euroianCities = Publishers.Merge(germanCities, italianCities)
        
        _ = euroianCities.sink(receiveValue: { (city ) in
            print("💥 \(city) is a city in europe")
        })
        
        germanCities.send("Munich")
        germanCities.send("Berlin")
        italianCities.send("Milano")
        italianCities.send("Rome")
    }
    
    // CombineLatest Trial Error
    func testArlindCode6() {
        
        let selectedFilter = PassthroughSubject<String, Never>()
        let searchText = PassthroughSubject<String, Never>()
        
        let publisher = Publishers.CombineLatest(selectedFilter,searchText)
        
        publisher
            .map { sFilter, sText in
                return "\(sFilter) \(sText)" }
        publisher.sink { (value) in
            print("💥 Value is : \(value)")
        }
        print(type(of: publisher))  // CombineLatest<PassthroughSubject<String, Never>, PassthroughSubject<String, Never>>
    }
    
    // Scan
    func testArlindCode7() {
        _ = Publishers.Sequence<[Int], Never>(sequence: [1,2,3,4,5])
            .flatMap { Just ($0)}
            .scan(0, +)
            .sink(receiveValue: { (value) in
                print(value)
            })
    }
    
    // receive data on another queue.
    
    func testRog() {
        let subject = PassthroughSubject<Int, Never>()
        let api = subject.eraseToAnyPublisher()
        let cancellable = api
            .receive(on: DispatchQueue.global())
            .flatMap { value -> AnyPublisher<String, Never> in
                print("Flat mapped \(value) - main thread? \(Thread.isMainThread)")
                return Just("\(value)").eraseToAnyPublisher()
                
        }
            
        .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
                print("Completed - main thread? \(Thread.isMainThread)")
            }, receiveValue: { value in
                print("Received \(value) - main thread? \(Thread.isMainThread)")
            })
        
        subject.send(99)
    }
    
    // How to read detailDetail?
    // ❌ Beta 3 test will be successful but not able to read detailDetail its an failure
    // ❌ Beta 4 test will be successful but no data is received
    
    func testJsonData() {
        
        let expectation = XCTestExpectation(description: "Data provided via jsondata")

        let jsondata = """
                {
                "id": 948783,
                "title": "Pay online using your Visa Signature or Visa Infinite Card and get 10% cashback up to ₹100 on one transaction during offer period.",
                "off_percent": "",
                "store": "Amazon",
                "current_price": 0
                    }
        """

        struct Hub: Codable {
            let id: Int
            let title: String
            let offPercent, store: String
            let currentPrice: Int
//            let dealDetail: String
            
            enum CodingKeys: String, CodingKey {
                case id, title
                case offPercent = "off_percent"
                case store
                case currentPrice = "current_price"
//                case dealDetail = "deal_detail"
            }
        }
        // setup Publisher is of type Data, Error
        let simpleControlledPublisher = PassthroughSubject<Data, Never>()

//        let simpleControlledPublisher = PassthroughSubject<Data, Error>()
        
        let myData = simpleControlledPublisher
            .map({ (data) -> Data in
                return Data(data)
            })
            .decode(type: Hub.self, decoder: JSONDecoder())
            
            
//            .flatMap { data in // takes a String in and returns a Publisher
//                return Just(data)
//                    .decode(type: Hub.self, decoder: JSONDecoder())
//        }
        .eraseToAnyPublisher()
        
        .sink(receiveCompletion: { completion in
            print("✅ .sink() received the completion:", String(describing: completion))
            switch completion {
            case .finished:
                expectation.fulfill()
                break
            case .failure(let anError):
                print("received error: ", anError)
                XCTFail("case .failure")
                break
            }
        }, receiveValue: { stringValue in
            print("✅.sink() received \(stringValue)")
        })
        
        simpleControlledPublisher.send(Data(jsondata.utf8))
        // simpleControlledPublisher.send(jsondata!)
        simpleControlledPublisher.send(completion: .finished)
        
      //  XCTAssertNotNil(myData)
        wait(for: [expectation], timeout: 5.0)
        
    }
    
    func testSimpleMutating() {
        struct Town {
            var population = 5422
            var numberOfStopLights = 4
            
            func printDescription() {
                print("💥 Population : \(population) number of stoplights: \(numberOfStopLights)")
            }
            
            mutating func changePopulation(by amount: Int) {
                population += amount
            }
        }
        var myTown = Town()
        myTown.changePopulation(by: 500)
        myTown.printDescription()
    }
    
    // This is failing
    func testjsonhtmldecode() {

        struct Models: Codable{
            let id: Int
            let title, offPercent, store: String
            let currentPrice: Int
            let dealDetail: String

            enum CodingKeys: String, CodingKey {
                case id, title
                case offPercent = "off_percent"
                case store
                case currentPrice = "current_price"
                case dealDetail = "deal_detail"
            }
        }
        // setup
        let expectation = XCTestExpectation(description: "Download from \(String(describing: glURL!))")

        let remoteDataPublisher = URLSession.shared.dataTaskPublisher(for: glURL!)
            // the dataTaskPublisher output combination is (data: Data, response: URLResponse)
            .map { $0.data}
            .decode(type: Models.self, decoder: JSONDecoder())
            .subscribe(on: self.myBackgroundQueue!)
            .eraseToAnyPublisher()

        // validate
        // Complete sink has two closures

        let _ = remoteDataPublisher
            .sink(receiveCompletion: { fini in
                switch fini {
                case .finished :
                    print("✅ .sink() receiveCompletion", String(describing: fini))
                    expectation.fulfill()
                    break
                case .failure:
                    print("❌ Error in receiveCompletion")
                    XCTFail("case is .failure")
                    break
                }
            }, receiveValue: { someValue in
                print("✅ .sink() receiveValue \(someValue)\n")
            })
        
        wait(for: [expectation], timeout: 5.0)
    }
}


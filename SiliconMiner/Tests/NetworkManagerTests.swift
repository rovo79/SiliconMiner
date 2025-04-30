import XCTest
@testable import SiliconMiner

class NetworkManagerTests: XCTestCase {
    var networkManager: NetworkManager!
    var mockSession: URLSessionMock!

    override func setUp() {
        super.setUp()
        mockSession = URLSessionMock()
        networkManager = NetworkManager(session: mockSession)
    }

    override func tearDown() {
        networkManager = nil
        mockSession = nil
        super.tearDown()
    }

    func testAuthenticateSuccess() {
        let expectation = self.expectation(description: "Authentication success")
        mockSession.nextData = "{\"success\": true}".data(using: .utf8)

        networkManager.authenticate(username: "testuser", password: "testpassword") { result in
            switch result {
            case .success(let success):
                XCTAssertTrue(success)
            case .failure:
                XCTFail("Expected success, but got failure")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testAuthenticateFailure() {
        let expectation = self.expectation(description: "Authentication failure")
        mockSession.nextData = "{\"success\": false}".data(using: .utf8)

        networkManager.authenticate(username: "testuser", password: "testpassword") { result in
            switch result {
            case .success(let success):
                XCTAssertFalse(success)
            case .failure:
                XCTFail("Expected success, but got failure")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testRequestMiningJobSuccess() {
        let expectation = self.expectation(description: "Request mining job success")
        mockSession.nextData = "{\"inputData\": [1.0, 2.0, 3.0]}".data(using: .utf8)

        networkManager.requestMiningJob { result in
            switch result {
            case .success(let jobData):
                XCTAssertEqual(jobData["inputData"] as? [Float], [1.0, 2.0, 3.0])
            case .failure:
                XCTFail("Expected success, but got failure")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testRequestMiningJobFailure() {
        let expectation = self.expectation(description: "Request mining job failure")
        mockSession.nextError = NSError(domain: "NetworkManager", code: -1, userInfo: nil)

        networkManager.requestMiningJob { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error):
                XCTAssertEqual(error.domain, "NetworkManager")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testSubmitMiningResultSuccess() {
        let expectation = self.expectation(description: "Submit mining result success")
        mockSession.nextData = "{\"success\": true}".data(using: .utf8)
        let resultData: [String: Any] = ["outputData": [1.0, 2.0, 3.0]]

        networkManager.submitMiningResult(result: resultData) { result in
            switch result {
            case .success(let success):
                XCTAssertTrue(success)
            case .failure:
                XCTFail("Expected success, but got failure")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testSubmitMiningResultFailure() {
        let expectation = self.expectation(description: "Submit mining result failure")
        mockSession.nextError = NSError(domain: "NetworkManager", code: -1, userInfo: nil)
        let resultData: [String: Any] = ["outputData": [1.0, 2.0, 3.0]]

        networkManager.submitMiningResult(result: resultData) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error):
                XCTAssertEqual(error.domain, "NetworkManager")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}

class URLSessionMock: URLSession {
    var nextData: Data?
    var nextError: Error?

    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return URLSessionDataTaskMock {
            completionHandler(self.nextData, nil, self.nextError)
        }
    }
}

class URLSessionDataTaskMock: URLSessionDataTask {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    override func resume() {
        closure()
    }
}

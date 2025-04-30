import XCTest
@testable import SiliconMiner

class PoolManagerTests: XCTestCase {
    var poolManager: PoolManager!
    var mockNetworkManager: NetworkManagerMock!

    override func setUp() {
        super.setUp()
        mockNetworkManager = NetworkManagerMock()
        poolManager = PoolManager(networkManager: mockNetworkManager)
    }

    override func tearDown() {
        poolManager = nil
        mockNetworkManager = nil
        super.tearDown()
    }

    func testAddPool() {
        let pool = MiningPool(url: "https://miningpool.com", username: "user", password: "pass")
        poolManager.addPool(pool)
        XCTAssertTrue(poolManager.pools.contains(where: { $0.url == pool.url }))
    }

    func testRemovePool() {
        let pool = MiningPool(url: "https://miningpool.com", username: "user", password: "pass")
        poolManager.addPool(pool)
        poolManager.removePool(pool)
        XCTAssertFalse(poolManager.pools.contains(where: { $0.url == pool.url }))
    }

    func testSelectBestPool() {
        let pool1 = MiningPool(url: "https://miningpool1.com", username: "user1", password: "pass1")
        let pool2 = MiningPool(url: "https://miningpool2.com", username: "user2", password: "pass2")
        poolManager.addPool(pool1)
        poolManager.addPool(pool2)
        poolManager.selectBestPool()
        XCTAssertEqual(poolManager.currentPool?.url, pool1.url)
    }

    func testConnectToPoolSuccess() {
        let expectation = self.expectation(description: "Connect to pool success")
        let pool = MiningPool(url: "https://miningpool.com", username: "user", password: "pass")
        poolManager.addPool(pool)
        poolManager.selectBestPool()
        mockNetworkManager.nextResult = .success(true)

        poolManager.connectToPool { result in
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

    func testConnectToPoolFailure() {
        let expectation = self.expectation(description: "Connect to pool failure")
        let pool = MiningPool(url: "https://miningpool.com", username: "user", password: "pass")
        poolManager.addPool(pool)
        poolManager.selectBestPool()
        mockNetworkManager.nextResult = .failure(NSError(domain: "PoolManager", code: -1, userInfo: nil))

        poolManager.connectToPool { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error):
                XCTAssertEqual(error.domain, "PoolManager")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testSwitchPool() {
        let expectation = self.expectation(description: "Switch pool")
        let pool1 = MiningPool(url: "https://miningpool1.com", username: "user1", password: "pass1")
        let pool2 = MiningPool(url: "https://miningpool2.com", username: "user2", password: "pass2")
        poolManager.addPool(pool1)
        poolManager.addPool(pool2)
        poolManager.selectBestPool()
        mockNetworkManager.nextResult = .success(true)

        poolManager.switchPool { result in
            switch result {
            case .success(let success):
                XCTAssertTrue(success)
                XCTAssertEqual(self.poolManager.currentPool?.url, pool2.url)
            case .failure:
                XCTFail("Expected success, but got failure")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testRequestMiningJobSuccess() {
        let expectation = self.expectation(description: "Request mining job success")
        mockNetworkManager.nextResult = .success(["inputData": [1.0, 2.0, 3.0]])

        poolManager.requestMiningJob { result in
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
        mockNetworkManager.nextResult = .failure(NSError(domain: "PoolManager", code: -1, userInfo: nil))

        poolManager.requestMiningJob { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error):
                XCTAssertEqual(error.domain, "PoolManager")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testSubmitMiningResultSuccess() {
        let expectation = self.expectation(description: "Submit mining result success")
        mockNetworkManager.nextResult = .success(true)
        let resultData: [String: Any] = ["outputData": [1.0, 2.0, 3.0]]

        poolManager.submitMiningResult(result: resultData) { result in
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
        mockNetworkManager.nextResult = .failure(NSError(domain: "PoolManager", code: -1, userInfo: nil))
        let resultData: [String: Any] = ["outputData": [1.0, 2.0, 3.0]]

        poolManager.submitMiningResult(result: resultData) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error):
                XCTAssertEqual(error.domain, "PoolManager")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}

class NetworkManagerMock: NetworkManager {
    var nextResult: Result<Any, Error>?

    override func authenticate(username: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        if let result = nextResult as? Result<Bool, Error> {
            completion(result)
        }
    }

    override func requestMiningJob(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        if let result = nextResult as? Result<[String: Any], Error> {
            completion(result)
        }
    }

    override func submitMiningResult(result: [String: Any], completion: @escaping (Result<Bool, Error>) -> Void) {
        if let result = nextResult as? Result<Bool, Error> {
            completion(result)
        }
    }
}

import XCTest
@testable import SiliconMiner

class ParallelizeCPUTests: XCTestCase {

    var parallelizeCPU: ParallelizeCPU!

    override func setUp() {
        super.setUp()
        parallelizeCPU = ParallelizeCPU()
    }

    override func tearDown() {
        parallelizeCPU = nil
        super.tearDown()
    }

    func testParallelizeWork() {
        let expectation = XCTestExpectation(description: "Parallelize work")
        let workItems = [
            { expectation.fulfill() },
            { expectation.fulfill() },
            { expectation.fulfill() }
        ]

        parallelizeCPU.parallelizeWork(workItems: workItems)

        wait(for: [expectation], timeout: 1.0)
    }

    func testParallelizeSIMDWork() {
        let input: [Float] = [1.0, 2.0, 3.0, 4.0]
        let expectedOutput: [Float] = [2.0, 4.0, 6.0, 8.0]

        let output = parallelizeCPU.parallelizeSIMDWork(input: input)

        XCTAssertEqual(output, expectedOutput, "Parallelize SIMD work output is incorrect")
    }

    func testOptimizeMemoryUsage() {
        let input: [Float] = [1.0, 2.0, 3.0, 4.0]
        let expectedOutput: [Float] = [2.0, 4.0, 6.0, 8.0]

        let output = parallelizeCPU.optimizeMemoryUsage(input: input)

        XCTAssertEqual(output, expectedOutput, "Optimize memory usage output is incorrect")
    }
}

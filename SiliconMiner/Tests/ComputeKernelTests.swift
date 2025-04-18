import XCTest
@testable import SiliconMiner

class ComputeKernelTests: XCTestCase {

    var device: MTLDevice!
    var computeKernel: ComputeKernel!

    override func setUp() {
        super.setUp()
        device = MTLCreateSystemDefaultDevice()
        computeKernel = ComputeKernel(device: device)
    }

    override func tearDown() {
        computeKernel = nil
        device = nil
        super.tearDown()
    }

    func testComputeKernelFunction() {
        let input = KernelInput(data: [1.0, 2.0, 3.0, 4.0])
        let expectedOutput = KernelOutput(data: [2.0, 4.0, 6.0, 8.0])

        let output = computeKernel.execute(input: input)

        XCTAssertEqual(output.data, expectedOutput.data, "Compute kernel output is incorrect")
    }

    func testComputeKernelWithEmptyInput() {
        let input = KernelInput(data: [])
        let expectedOutput = KernelOutput(data: [])

        let output = computeKernel.execute(input: input)

        XCTAssertEqual(output.data, expectedOutput.data, "Compute kernel output for empty input is incorrect")
    }

    func testComputeKernelWithNegativeValues() {
        let input = KernelInput(data: [-1.0, -2.0, -3.0, -4.0])
        let expectedOutput = KernelOutput(data: [-2.0, -4.0, -6.0, -8.0])

        let output = computeKernel.execute(input: input)

        XCTAssertEqual(output.data, expectedOutput.data, "Compute kernel output for negative values is incorrect")
    }

    func testComputeKernelPerformance() {
        let input = KernelInput(data: Array(repeating: 1.0, count: 1000))

        measure {
            _ = computeKernel.execute(input: input)
        }
    }
}

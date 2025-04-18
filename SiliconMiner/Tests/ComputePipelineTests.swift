import XCTest
import Metal
@testable import SiliconMiner

class ComputePipelineTests: XCTestCase {

    var device: MTLDevice!
    var computePipeline: ComputePipeline!

    override func setUp() {
        super.setUp()
        device = MTLCreateSystemDefaultDevice()
        computePipeline = ComputePipeline(device: device, kernelFunction: computeKernelFunction())
    }

    override func tearDown() {
        computePipeline = nil
        device = nil
        super.tearDown()
    }

    func testComputePipelineExecution() {
        let inputData: [Float] = [1.0, 2.0, 3.0, 4.0]
        let inputBuffer = device.makeBuffer(bytes: inputData, length: inputData.count * MemoryLayout<Float>.size, options: [])
        let outputBuffer = device.makeBuffer(length: inputData.count * MemoryLayout<Float>.size, options: [])

        let gridSize = MTLSize(width: inputData.count, height: 1, depth: 1)
        let threadGroupSize = MTLSize(width: min(computePipeline.pipelineState.maxTotalThreadsPerThreadgroup, inputData.count), height: 1, depth: 1)

        computePipeline.execute(inputBuffer: inputBuffer!, outputBuffer: outputBuffer!, gridSize: gridSize, threadGroupSize: threadGroupSize)

        let outputPointer = outputBuffer?.contents().bindMemory(to: Float.self, capacity: inputData.count)
        let outputData = Array(UnsafeBufferPointer(start: outputPointer, count: inputData.count))

        let expectedOutputData: [Float] = [2.0, 4.0, 6.0, 8.0]
        XCTAssertEqual(outputData, expectedOutputData, "Compute pipeline output is incorrect")
    }

    func testComputePipelineWithEmptyInput() {
        let inputData: [Float] = []
        let inputBuffer = device.makeBuffer(bytes: inputData, length: inputData.count * MemoryLayout<Float>.size, options: [])
        let outputBuffer = device.makeBuffer(length: inputData.count * MemoryLayout<Float>.size, options: [])

        let gridSize = MTLSize(width: inputData.count, height: 1, depth: 1)
        let threadGroupSize = MTLSize(width: min(computePipeline.pipelineState.maxTotalThreadsPerThreadgroup, inputData.count), height: 1, depth: 1)

        computePipeline.execute(inputBuffer: inputBuffer!, outputBuffer: outputBuffer!, gridSize: gridSize, threadGroupSize: threadGroupSize)

        let outputPointer = outputBuffer?.contents().bindMemory(to: Float.self, capacity: inputData.count)
        let outputData = Array(UnsafeBufferPointer(start: outputPointer, count: inputData.count))

        let expectedOutputData: [Float] = []
        XCTAssertEqual(outputData, expectedOutputData, "Compute pipeline output for empty input is incorrect")
    }

    func testComputePipelineWithNegativeValues() {
        let inputData: [Float] = [-1.0, -2.0, -3.0, -4.0]
        let inputBuffer = device.makeBuffer(bytes: inputData, length: inputData.count * MemoryLayout<Float>.size, options: [])
        let outputBuffer = device.makeBuffer(length: inputData.count * MemoryLayout<Float>.size, options: [])

        let gridSize = MTLSize(width: inputData.count, height: 1, depth: 1)
        let threadGroupSize = MTLSize(width: min(computePipeline.pipelineState.maxTotalThreadsPerThreadgroup, inputData.count), height: 1, depth: 1)

        computePipeline.execute(inputBuffer: inputBuffer!, outputBuffer: outputBuffer!, gridSize: gridSize, threadGroupSize: threadGroupSize)

        let outputPointer = outputBuffer?.contents().bindMemory(to: Float.self, capacity: inputData.count)
        let outputData = Array(UnsafeBufferPointer(start: outputPointer, count: inputData.count))

        let expectedOutputData: [Float] = [-2.0, -4.0, -6.0, -8.0]
        XCTAssertEqual(outputData, expectedOutputData, "Compute pipeline output for negative values is incorrect")
    }

    func testComputePipelinePerformance() {
        let inputData: [Float] = Array(repeating: 1.0, count: 1000)
        let inputBuffer = device.makeBuffer(bytes: inputData, length: inputData.count * MemoryLayout<Float>.size, options: [])
        let outputBuffer = device.makeBuffer(length: inputData.count * MemoryLayout<Float>.size, options: [])

        let gridSize = MTLSize(width: inputData.count, height: 1, depth: 1)
        let threadGroupSize = MTLSize(width: min(computePipeline.pipelineState.maxTotalThreadsPerThreadgroup, inputData.count), height: 1, depth: 1)

        measure {
            computePipeline.execute(inputBuffer: inputBuffer!, outputBuffer: outputBuffer!, gridSize: gridSize, threadGroupSize: threadGroupSize)
        }
    }
}

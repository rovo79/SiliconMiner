import XCTest
import Metal
@testable import SiliconMiner

class IntegrationTests: XCTestCase {
    var device: MTLDevice!
    var computeKernel: ComputeKernel!
    var computePipeline: ComputePipeline!
    var dispatchKernel: DispatchKernel!
    var optimizeKernel: OptimizeKernel!
    var parallelizeCPU: ParallelizeCPU!

    override func setUp() {
        super.setUp()
        device = MTLCreateSystemDefaultDevice()
        computeKernel = ComputeKernel(device: device)
        computePipeline = ComputePipeline(device: device, kernelFunction: computeKernelFunction())
        dispatchKernel = DispatchKernel(device: device, pipelineState: computePipeline.pipelineState)
        optimizeKernel = OptimizeKernel(device: device, pipelineState: computePipeline.pipelineState)
        parallelizeCPU = ParallelizeCPU()
    }

    func testIntegration() {
        let input = KernelInput(data: [1.0, 2.0, 3.0, 4.0])
        let output = computeKernel.execute(input: input)
        XCTAssertEqual(output.data, [2.0, 4.0, 6.0, 8.0])

        let inputBuffer = device.makeBuffer(bytes: input.data, length: input.data.count * MemoryLayout<Float>.size, options: [])
        let outputBuffer = device.makeBuffer(length: input.data.count * MemoryLayout<Float>.size, options: [])
        let gridSize = MTLSize(width: input.data.count, height: 1, depth: 1)
        let threadGroupSize = MTLSize(width: min(computePipeline.pipelineState.maxTotalThreadsPerThreadgroup, input.data.count), height: 1, depth: 1)

        computePipeline.execute(inputBuffer: inputBuffer!, outputBuffer: outputBuffer!, gridSize: gridSize, threadGroupSize: threadGroupSize)
        let outputPointer = outputBuffer?.contents().bindMemory(to: Float.self, capacity: input.data.count)
        let outputData = Array(UnsafeBufferPointer(start: outputPointer, count: input.data.count))
        XCTAssertEqual(outputData, [2.0, 4.0, 6.0, 8.0])

        dispatchKernel.dispatchKernel(inputBuffer: inputBuffer!, outputBuffer: outputBuffer!, gridSize: gridSize, threadGroupSize: threadGroupSize)
        let dispatchOutputPointer = outputBuffer?.contents().bindMemory(to: Float.self, capacity: input.data.count)
        let dispatchOutputData = Array(UnsafeBufferPointer(start: dispatchOutputPointer, count: input.data.count))
        XCTAssertEqual(dispatchOutputData, [2.0, 4.0, 6.0, 8.0])

        optimizeKernel.optimizeKernel(inputBuffer: inputBuffer!, outputBuffer: outputBuffer!, gridSize: gridSize, threadGroupSize: threadGroupSize)
        let optimizeOutputPointer = outputBuffer?.contents().bindMemory(to: Float.self, capacity: input.data.count)
        let optimizeOutputData = Array(UnsafeBufferPointer(start: optimizeOutputPointer, count: input.data.count))
        XCTAssertEqual(optimizeOutputData, [2.0, 4.0, 6.0, 8.0])

        let parallelOutput = parallelizeCPU.parallelizeSIMDWork(input: input.data)
        XCTAssertEqual(parallelOutput, [2.0, 4.0, 6.0, 8.0])
    }
}

import XCTest
import Metal
@testable import SiliconMiner

class DispatchKernelTests: XCTestCase {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLComputePipelineState!
    var dispatchKernel: DispatchKernel!

    override func setUpWithError() throws {
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
        let library = try device.makeDefaultLibrary(bundle: Bundle(for: type(of: self)))
        let function = library.makeFunction(name: "computeKernel")!
        pipelineState = try device.makeComputePipelineState(function: function)
        dispatchKernel = DispatchKernel(device: device, pipelineState: pipelineState)
    }

    func testDispatchKernel() throws {
        let inputData: [Float] = [1.0, 2.0, 3.0, 4.0]
        let inputBuffer = device.makeBuffer(bytes: inputData, length: inputData.count * MemoryLayout<Float>.size, options: [])
        let outputBuffer = device.makeBuffer(length: inputData.count * MemoryLayout<Float>.size, options: [])

        let gridSize = MTLSize(width: inputData.count, height: 1, depth: 1)
        let threadGroupSize = MTLSize(width: min(pipelineState.maxTotalThreadsPerThreadgroup, inputData.count), height: 1, depth: 1)

        dispatchKernel.dispatchKernel(inputBuffer: inputBuffer!, outputBuffer: outputBuffer!, gridSize: gridSize, threadGroupSize: threadGroupSize)

        let outputPointer = outputBuffer?.contents().bindMemory(to: Float.self, capacity: inputData.count)
        let outputData = Array(UnsafeBufferPointer(start: outputPointer, count: inputData.count))

        XCTAssertEqual(outputData, [2.0, 4.0, 6.0, 8.0], "Output data does not match expected values")
    }
}

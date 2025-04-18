import XCTest
import Metal
@testable import SiliconMiner

class OptimizeKernelTests: XCTestCase {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLComputePipelineState!
    var optimizeKernel: OptimizeKernel!

    override func setUpWithError() throws {
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
        let library = try device.makeDefaultLibrary(bundle: Bundle(for: type(of: self)))
        let function = library.makeFunction(name: "computeKernel")!
        pipelineState = try device.makeComputePipelineState(function: function)
        optimizeKernel = OptimizeKernel(device: device, pipelineState: pipelineState)
    }

    func testOptimizeKernel() throws {
        let inputData: [Float] = [1.0, 2.0, 3.0, 4.0]
        let inputBuffer = device.makeBuffer(bytes: inputData, length: inputData.count * MemoryLayout<Float>.size, options: [])
        let outputBuffer = device.makeBuffer(length: inputData.count * MemoryLayout<Float>.size, options: [])

        let gridSize = MTLSize(width: inputData.count, height: 1, depth: 1)
        let threadGroupSize = MTLSize(width: min(pipelineState.maxTotalThreadsPerThreadgroup, inputData.count), height: 1, depth: 1)

        optimizeKernel.optimizeKernel(inputBuffer: inputBuffer!, outputBuffer: outputBuffer!, gridSize: gridSize, threadGroupSize: threadGroupSize)

        let outputPointer = outputBuffer?.contents().bindMemory(to: Float.self, capacity: inputData.count)
        let outputData = Array(UnsafeBufferPointer(start: outputPointer, count: inputData.count))

        XCTAssertEqual(outputData, [2.0, 4.0, 6.0, 8.0], "Output data does not match expected values")
    }

    func testCacheResult() throws {
        let inputData: [Float] = [1.0, 2.0, 3.0, 4.0]
        let inputBuffer = device.makeBuffer(bytes: inputData, length: inputData.count * MemoryLayout<Float>.size, options: [])
        optimizeKernel.cacheResult(key: "testKey", buffer: inputBuffer!)
        let cachedBuffer = optimizeKernel.getCachedResult(key: "testKey")
        XCTAssertNotNil(cachedBuffer, "Cached buffer should not be nil")
    }

    func testProfileKernelExecution() throws {
        let inputData: [Float] = [1.0, 2.0, 3.0, 4.0]
        let inputBuffer = device.makeBuffer(bytes: inputData, length: inputData.count * MemoryLayout<Float>.size, options: [])
        let outputBuffer = device.makeBuffer(length: inputData.count * MemoryLayout<Float>.size, options: [])

        let gridSize = MTLSize(width: inputData.count, height: 1, depth: 1)
        let threadGroupSize = MTLSize(width: min(pipelineState.maxTotalThreadsPerThreadgroup, inputData.count), height: 1, depth: 1)

        optimizeKernel.profileKernelExecution(inputBuffer: inputBuffer!, outputBuffer: outputBuffer!, gridSize: gridSize, threadGroupSize: threadGroupSize)
    }

    func testLoadBalanceKernelExecution() throws {
        let inputData1: [Float] = [1.0, 2.0, 3.0, 4.0]
        let inputData2: [Float] = [5.0, 6.0, 7.0, 8.0]
        let inputBuffer1 = device.makeBuffer(bytes: inputData1, length: inputData1.count * MemoryLayout<Float>.size, options: [])
        let inputBuffer2 = device.makeBuffer(bytes: inputData2, length: inputData2.count * MemoryLayout<Float>.size, options: [])
        let outputBuffer1 = device.makeBuffer(length: inputData1.count * MemoryLayout<Float>.size, options: [])
        let outputBuffer2 = device.makeBuffer(length: inputData2.count * MemoryLayout<Float>.size, options: [])

        let gridSize = MTLSize(width: inputData1.count, height: 1, depth: 1)
        let threadGroupSize = MTLSize(width: min(pipelineState.maxTotalThreadsPerThreadgroup, inputData1.count), height: 1, depth: 1)

        optimizeKernel.loadBalanceKernelExecution(inputBuffers: [inputBuffer1!, inputBuffer2!], outputBuffers: [outputBuffer1!, outputBuffer2!], gridSize: gridSize, threadGroupSize: threadGroupSize)
    }

    func testOptimizeDataTransfer() throws {
        let inputData: [Float] = [1.0, 2.0, 3.0, 4.0]
        let inputBuffer = device.makeBuffer(bytes: inputData, length: inputData.count * MemoryLayout<Float>.size, options: [])
        let outputBuffer = device.makeBuffer(length: inputData.count * MemoryLayout<Float>.size, options: [])

        optimizeKernel.optimizeDataTransfer(inputBuffer: inputBuffer!, outputBuffer: outputBuffer!)
    }

    func testAdaptiveKernelExecution() throws {
        let inputData: [Float] = [1.0, 2.0, 3.0, 4.0]
        let inputBuffer = device.makeBuffer(bytes: inputData, length: inputData.count * MemoryLayout<Float>.size, options: [])
        let outputBuffer = device.makeBuffer(length: inputData.count * MemoryLayout<Float>.size, options: [])

        let gridSize = MTLSize(width: inputData.count, height: 1, depth: 1)
        let threadGroupSize = MTLSize(width: min(pipelineState.maxTotalThreadsPerThreadgroup, inputData.count), height: 1, depth: 1)

        optimizeKernel.adaptiveKernelExecution(inputBuffer: inputBuffer!, outputBuffer: outputBuffer!, gridSize: gridSize, threadGroupSize: threadGroupSize)
    }
}

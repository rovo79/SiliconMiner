import XCTest
import Metal
import os.log

class PerformanceTests: XCTestCase {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLComputePipelineState!
    let log = OSLog(subsystem: "com.siliconminer", category: "PerformanceTests")

    override func setUp() {
        super.setUp()
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
        let library = try! device.makeLibrary(source: computeKernelFunction(), options: nil)
        let function = library.makeFunction(name: "computeKernel")!
        pipelineState = try! device.makeComputePipelineState(function: function)
    }

    func testKernelExecutionPerformance() {
        let input = KernelInput(data: Array(repeating: 1.0, count: 1000000))
        let computeKernel = ComputeKernel(device: device)
        measure {
            let _ = computeKernel.execute(input: input)
        }
    }

    func testPipelineExecutionPerformance() {
        let input = KernelInput(data: Array(repeating: 1.0, count: 1000000))
        let inputBuffer = device.makeBuffer(bytes: input.data, length: input.data.count * MemoryLayout<Float>.size, options: [])
        let outputBuffer = device.makeBuffer(length: input.data.count * MemoryLayout<Float>.size, options: [])
        let gridSize = MTLSize(width: input.data.count, height: 1, depth: 1)
        let threadGroupSize = MTLSize(width: min(pipelineState.maxTotalThreadsPerThreadgroup, input.data.count), height: 1, depth: 1)
        let computePipeline = ComputePipeline(device: device, kernelFunction: computeKernelFunction())
        measure {
            computePipeline.execute(inputBuffer: inputBuffer!, outputBuffer: outputBuffer!, gridSize: gridSize, threadGroupSize: threadGroupSize)
        }
    }

    func testDispatchKernelPerformance() {
        let input = KernelInput(data: Array(repeating: 1.0, count: 1000000))
        let inputBuffer = device.makeBuffer(bytes: input.data, length: input.data.count * MemoryLayout<Float>.size, options: [])
        let outputBuffer = device.makeBuffer(length: input.data.count * MemoryLayout<Float>.size, options: [])
        let gridSize = MTLSize(width: input.data.count, height: 1, depth: 1)
        let threadGroupSize = MTLSize(width: min(pipelineState.maxTotalThreadsPerThreadgroup, input.data.count), height: 1, depth: 1)
        let dispatchKernel = DispatchKernel(device: device, pipelineState: pipelineState)
        measure {
            dispatchKernel.dispatchKernel(inputBuffer: inputBuffer!, outputBuffer: outputBuffer!, gridSize: gridSize, threadGroupSize: threadGroupSize)
        }
    }

    func testOptimizeKernelPerformance() {
        let input = KernelInput(data: Array(repeating: 1.0, count: 1000000))
        let inputBuffer = device.makeBuffer(bytes: input.data, length: input.data.count * MemoryLayout<Float>.size, options: [])
        let outputBuffer = device.makeBuffer(length: input.data.count * MemoryLayout<Float>.size, options: [])
        let gridSize = MTLSize(width: input.data.count, height: 1, depth: 1)
        let threadGroupSize = MTLSize(width: min(pipelineState.maxTotalThreadsPerThreadgroup, input.data.count), height: 1, depth: 1)
        let optimizeKernel = OptimizeKernel(device: device, pipelineState: pipelineState)
        measure {
            optimizeKernel.optimizeKernel(inputBuffer: inputBuffer!, outputBuffer: outputBuffer!, gridSize: gridSize, threadGroupSize: threadGroupSize)
        }
    }

    func testParallelizeCPUPerformance() {
        let input = Array(repeating: 1.0, count: 1000000)
        let parallelizeCPU = ParallelizeCPU()
        measure {
            let _ = parallelizeCPU.parallelizeSIMDWork(input: input)
        }
    }
}

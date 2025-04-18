import Metal
import os.log
import simd

class ComputePipeline {
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    var pipelineState: MTLComputePipelineState
    let log = OSLog(subsystem: "com.siliconminer", category: "ComputePipeline")

    init(device: MTLDevice, kernelFunction: String) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        let library = try! device.makeLibrary(source: kernelFunction, options: nil)
        let function = library.makeFunction(name: "computeKernel")!
        self.pipelineState = try! device.makeComputePipelineState(function: function)
    }

    func execute(inputBuffer: MTLBuffer, outputBuffer: MTLBuffer, gridSize: MTLSize, threadGroupSize: MTLSize) {
        do {
            let commandBuffer = commandQueue.makeCommandBuffer()!
            let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
            commandEncoder.setComputePipelineState(pipelineState)
            commandEncoder.setBuffer(inputBuffer, offset: 0, index: 0)
            commandEncoder.setBuffer(outputBuffer, offset: 0, index: 1)
            commandEncoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadGroupSize)
            commandEncoder.endEncoding()
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
        } catch {
            os_log("Error executing compute pipeline: %@", log: log, type: .error, error.localizedDescription)
        }
    }
}

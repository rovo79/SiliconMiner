import Metal
import os.log
import simd

class DispatchKernel {
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    var pipelineState: MTLComputePipelineState
    let log = OSLog(subsystem: "com.siliconminer", category: "DispatchKernel")

    init(device: MTLDevice, pipelineState: MTLComputePipelineState) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        self.pipelineState = pipelineState
    }

    func dispatchKernel(inputBuffer: MTLBuffer, outputBuffer: MTLBuffer, gridSize: MTLSize, threadGroupSize: MTLSize) {
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
            os_log("Error dispatching kernel: %@", log: log, type: .error, error.localizedDescription)
        }
    }
}

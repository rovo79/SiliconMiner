import Metal

class DispatchKernel {
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    var pipelineState: MTLComputePipelineState
    var networkManager: NetworkManager

    init(device: MTLDevice, pipelineState: MTLComputePipelineState) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        self.pipelineState = pipelineState
        self.networkManager = NetworkManager.shared
    }

    func dispatchKernel(inputBuffer: MTLBuffer, outputBuffer: MTLBuffer, gridSize: MTLSize, threadGroupSize: MTLSize) {
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        commandEncoder.setComputePipelineState(pipelineState)
        commandEncoder.setBuffer(inputBuffer, offset: 0, index: 0)
        commandEncoder.setBuffer(outputBuffer, offset: 0, index: 1)
        commandEncoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadGroupSize)
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }

    func receiveMiningJob(completion: @escaping (Result<MTLBuffer, Error>) -> Void) {
        networkManager.requestMiningJob { result in
            switch result {
            case .success(let jobData):
                // Parse jobData to create inputBuffer
                let inputData = jobData["inputData"] as? [Float] ?? []
                let inputBuffer = self.device.makeBuffer(bytes: inputData, length: inputData.count * MemoryLayout<Float>.size, options: [])
                completion(.success(inputBuffer!))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func submitMiningResult(resultBuffer: MTLBuffer, completion: @escaping (Result<Bool, Error>) -> Void) {
        let resultPointer = resultBuffer.contents().bindMemory(to: Float.self, capacity: resultBuffer.length / MemoryLayout<Float>.size)
        let resultData = Array(UnsafeBufferPointer(start: resultPointer, count: resultBuffer.length / MemoryLayout<Float>.size))
        let resultDict: [String: Any] = ["outputData": resultData]
        networkManager.submitMiningResult(result: resultDict, completion: completion)
    }

    func logNetworkCommunication(message: String) {
        print("Network Communication Log: \(message)")
    }
}

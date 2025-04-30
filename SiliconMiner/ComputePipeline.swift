import Metal

class ComputePipeline {
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    var pipelineState: MTLComputePipelineState
    var poolManager: PoolManager

    init(device: MTLDevice, kernelFunction: String) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        let library = try! device.makeLibrary(source: kernelFunction, options: nil)
        let function = library.makeFunction(name: "computeKernel")!
        self.pipelineState = try! device.makeComputePipelineState(function: function)
        self.poolManager = PoolManager.shared
    }

    func handlePoolSwitching() {
        poolManager.switchPool { result in
            switch result {
            case .success(let success):
                if success {
                    print("Switched to a new pool successfully.")
                } else {
                    print("Failed to switch to a new pool.")
                }
            case .failure(let error):
                print("Error switching pool: \(error.localizedDescription)")
            }
        }
    }

    func logPoolManagement(message: String) {
        print("Pool Management Log: \(message)")
    }
}

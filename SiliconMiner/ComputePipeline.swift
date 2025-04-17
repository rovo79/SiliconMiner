import Metal

class ComputePipeline {
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    var pipelineState: MTLComputePipelineState

    init(device: MTLDevice, kernelFunction: String) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        let library = try! device.makeLibrary(source: kernelFunction, options: nil)
        let function = library.makeFunction(name: "computeKernel")!
        self.pipelineState = try! device.makeComputePipelineState(function: function)
    }
}

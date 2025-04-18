import Foundation
import os.log
import simd

class ParallelizeCPU {
    let queue: DispatchQueue
    let log = OSLog(subsystem: "com.siliconminer", category: "ParallelizeCPU")

    init() {
        self.queue = DispatchQueue(label: "com.siliconminer.parallelizecpu", attributes: .concurrent)
    }

    func parallelizeWork(workItems: [() -> Void]) {
        do {
            DispatchQueue.concurrentPerform(iterations: workItems.count) { index in
                workItems[index]()
            }
        } catch {
            os_log("Error parallelizing work: %@", log: log, type: .error, error.localizedDescription)
        }
    }

    func parallelizeSIMDWork(input: [Float]) -> [Float] {
        let count = input.count
        var output = [Float](repeating: 0, count: count)
        let simdGroupSize = 4

        DispatchQueue.concurrentPerform(iterations: count / simdGroupSize) { index in
            let start = index * simdGroupSize
            let end = start + simdGroupSize
            let simdInput = simd_float4(input[start], input[start + 1], input[start + 2], input[start + 3])
            let simdOutput = simdInput * 2.0
            output[start] = simdOutput[0]
            output[start + 1] = simdOutput[1]
            output[start + 2] = simdOutput[2]
            output[start + 3] = simdOutput[3]
        }

        return output
    }

    func optimizeMemoryUsage(input: [Float]) -> [Float] {
        let count = input.count
        var output = [Float](repeating: 0, count: count)

        input.withUnsafeBufferPointer { inputBuffer in
            output.withUnsafeMutableBufferPointer { outputBuffer in
                DispatchQueue.concurrentPerform(iterations: count) { index in
                    outputBuffer[index] = inputBuffer[index] * 2.0
                }
            }
        }

        return output
    }
}

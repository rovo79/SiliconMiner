import Foundation

class ParallelizeCPU {
    let queue: DispatchQueue

    init() {
        self.queue = DispatchQueue(label: "com.siliconminer.parallelizecpu", attributes: .concurrent)
    }

    func parallelizeWork(workItems: [() -> Void]) {
        DispatchQueue.concurrentPerform(iterations: workItems.count) { index in
            workItems[index]()
        }
    }
}

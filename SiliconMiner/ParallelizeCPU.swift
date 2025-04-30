import Foundation

class ParallelizeCPU {
    let queue: DispatchQueue
    let networkManager: NetworkManager

    init() {
        self.queue = DispatchQueue(label: "com.siliconminer.parallelizecpu", attributes: .concurrent)
        self.networkManager = NetworkManager.shared
    }

    func parallelizeWork(workItems: [() -> Void]) {
        DispatchQueue.concurrentPerform(iterations: workItems.count) { index in
            workItems[index]()
        }
    }

    func receiveMiningJob(completion: @escaping (Result<[() -> Void], Error>) -> Void) {
        networkManager.requestMiningJob { result in
            switch result {
            case .success(let jobData):
                // Parse jobData to create workItems
                let workItems: [() -> Void] = jobData["workItems"] as? [() -> Void] ?? []
                completion(.success(workItems))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func submitMiningResult(result: [() -> Void], completion: @escaping (Result<Bool, Error>) -> Void) {
        let resultData: [String: Any] = ["workItems": result]
        networkManager.submitMiningResult(result: resultData, completion: completion)
    }

    func logNetworkCommunication(message: String) {
        print("Network Communication Log: \(message)")
    }
}

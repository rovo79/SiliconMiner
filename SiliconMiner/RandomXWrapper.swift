import Foundation
import RandomX

class RandomXWrapper {
    private var cache: OpaquePointer?
    private var dataset: OpaquePointer?
    private var vm: OpaquePointer?
    private var poolManager: PoolManager

    init() {
        randomx_init()
        self.poolManager = PoolManager.shared
    }

    deinit {
        if let vm = vm {
            randomx_destroy_vm(vm)
        }
        if let dataset = dataset {
            randomx_release_dataset(dataset)
        }
        if let cache = cache {
            randomx_release_cache(cache)
        }
    }

    func initializeCache(seed: Data) {
        cache = randomx_alloc_cache(RANDOMX_FLAG_DEFAULT)
        seed.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            randomx_init_cache(cache, bytes.baseAddress, seed.count)
        }
    }

    func initializeDataset() {
        dataset = randomx_alloc_dataset(RANDOMX_FLAG_DEFAULT)
        let datasetItemCount = randomx_dataset_item_count()
        DispatchQueue.concurrentPerform(iterations: datasetItemCount) { i in
            randomx_init_dataset(dataset, cache, UInt64(i))
        }
    }

    func createVM() {
        vm = randomx_create_vm(RANDOMX_FLAG_DEFAULT, cache, dataset)
    }

    func calculateHash(input: Data) -> Data {
        var hash = Data(count: 32)
        input.withUnsafeBytes { (inputBytes: UnsafeRawBufferPointer) in
            hash.withUnsafeMutableBytes { (hashBytes: UnsafeMutableRawBufferPointer) in
                randomx_calculate_hash(vm, inputBytes.baseAddress, input.count, hashBytes.baseAddress)
            }
        }
        return hash
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

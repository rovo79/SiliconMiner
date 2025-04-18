import Foundation

class CommandLineInterface {
    let miner: Miner

    init(miner: Miner) {
        self.miner = miner
    }

    func start() {
        print("Welcome to SiliconMiner!")
        print("Please enter a command (start, stop, status, exit):")

        while true {
            if let input = readLine() {
                switch input.lowercased() {
                case "start":
                    startMining()
                case "stop":
                    stopMining()
                case "status":
                    showStatus()
                case "exit":
                    print("Exiting SiliconMiner. Goodbye!")
                    return
                default:
                    print("Invalid command. Please enter a valid command (start, stop, status, exit):")
                }
            }
        }
    }

    private func startMining() {
        print("Starting the miner...")
        miner.start()
        print("Miner started.")
    }

    private func stopMining() {
        print("Stopping the miner...")
        miner.stop()
        print("Miner stopped.")
    }

    private func showStatus() {
        let status = miner.status()
        print("Miner status: \(status)")
    }
}

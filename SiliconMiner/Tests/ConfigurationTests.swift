import XCTest
@testable import SiliconMiner

class ConfigurationTests: XCTestCase {

    func testDevelopmentConfiguration() {
        let config = loadConfiguration(for: "development")
        XCTAssertEqual(config.environment, "development")
        XCTAssertEqual(config.apiEndpoint, "https://dev.api.siliconminer.com")
        XCTAssertEqual(config.loggingLevel, "debug")
    }

    func testProductionConfiguration() {
        let config = loadConfiguration(for: "production")
        XCTAssertEqual(config.environment, "production")
        XCTAssertEqual(config.apiEndpoint, "https://api.siliconminer.com")
        XCTAssertEqual(config.loggingLevel, "error")
    }

    func testTestingConfiguration() {
        let config = loadConfiguration(for: "testing")
        XCTAssertEqual(config.environment, "testing")
        XCTAssertEqual(config.apiEndpoint, "https://test.api.siliconminer.com")
        XCTAssertEqual(config.loggingLevel, "info")
    }

    private func loadConfiguration(for environment: String) -> Configuration {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "config.\(environment)", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try! decoder.decode(Configuration.self, from: data)
    }
}

struct Configuration: Codable {
    let environment: String
    let apiEndpoint: String
    let loggingLevel: String
}

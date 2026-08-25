import XCTest
@testable import CreditHub

final class KeychainManagerTests: XCTestCase {
    private let key = "com.credithub.app.tests.sampleKey"

    override func tearDownWithError() throws {
        try? KeychainManager.shared.delete(forKey: key)
        try super.tearDownWithError()
    }

    func test_saveAndLoad_roundTripsValue() throws {
        struct Sample: Codable, Equatable {
            let value: String
        }
        let sample = Sample(value: "hello")

        try KeychainManager.shared.save(sample, forKey: key)
        let loaded = try KeychainManager.shared.load(Sample.self, forKey: key)

        XCTAssertEqual(loaded, sample)
    }

    func test_load_whenKeyMissing_returnsNil() throws {
        let loaded = try KeychainManager.shared.load(String.self, forKey: "com.credithub.app.tests.missingKey")
        XCTAssertNil(loaded)
    }
}

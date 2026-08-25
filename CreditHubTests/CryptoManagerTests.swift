import XCTest
@testable import CreditHub

final class CryptoManagerTests: XCTestCase {
    override func tearDownWithError() throws {
        try? KeychainManager.shared.delete(forKey: "com.credithub.app.localEncryptionKey")
        try super.tearDownWithError()
    }

    func test_encryptThenDecrypt_roundTripsPlaintext() throws {
        let manager = CryptoManager()
        let plaintext = Data("sensitive account details".utf8)

        let ciphertext = try manager.encrypt(plaintext)
        let decrypted = try manager.decrypt(ciphertext)

        XCTAssertEqual(decrypted, plaintext)
        XCTAssertNotEqual(ciphertext, plaintext)
    }

    func test_decrypt_withTamperedCiphertext_throws() throws {
        let manager = CryptoManager()
        var ciphertext = try manager.encrypt(Data("sensitive".utf8))
        ciphertext[ciphertext.count - 1] ^= 0xFF

        XCTAssertThrowsError(try manager.decrypt(ciphertext))
    }
}

import Foundation
import CryptoKit

enum CryptoError: Error {
    case sealFailed
    case openFailed
}

/// AES-GCM helpers (CryptoKit) for encrypting local blobs that live outside the Keychain, e.g.
/// cached PII fields persisted in SwiftData. The symmetric key itself is generated once and stored
/// in the Keychain, never in plain SwiftData/UserDefaults storage.
final class CryptoManager {
    static let shared = CryptoManager()

    private let keychain: KeychainManager
    private let keyStorageKey = "com.credithub.app.localEncryptionKey"

    init(keychain: KeychainManager = .shared) {
        self.keychain = keychain
    }

    func encrypt(_ plaintext: Data) throws -> Data {
        let key = try symmetricKey()
        guard let sealedBox = try? AES.GCM.seal(plaintext, using: key), let combined = sealedBox.combined else {
            throw CryptoError.sealFailed
        }
        return combined
    }

    func decrypt(_ ciphertext: Data) throws -> Data {
        let key = try symmetricKey()
        let sealedBox = try AES.GCM.SealedBox(combined: ciphertext)
        guard let plaintext = try? AES.GCM.open(sealedBox, using: key) else {
            throw CryptoError.openFailed
        }
        return plaintext
    }

    private func symmetricKey() throws -> SymmetricKey {
        if let existingKeyData = try keychain.load(Data.self, forKey: keyStorageKey) {
            return SymmetricKey(data: existingKeyData)
        }
        let newKey = SymmetricKey(size: .bits256)
        let keyData = newKey.withUnsafeBytes { Data($0) }
        try keychain.save(keyData, forKey: keyStorageKey)
        return newKey
    }
}

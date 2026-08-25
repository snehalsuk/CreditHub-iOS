import CryptoKit
import Foundation

/// SPKI public-key pinning delegate. Only rejects connections once `Config.pinnedPublicKeyHashes` is
/// non-empty — with no pins configured it defers to the system's default TLS trust evaluation, so the
/// mock-API scaffold and early backend integration aren't blocked before real pins are captured.
final class CertificatePinningDelegate: NSObject, URLSessionDelegate {
    private let pinnedPublicKeyHashes: Set<String>

    init(pinnedPublicKeyHashes: Set<String>) {
        self.pinnedPublicKeyHashes = pinnedPublicKeyHashes
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard !pinnedPublicKeyHashes.isEmpty,
              challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        guard SecTrustEvaluateWithError(serverTrust, nil) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        guard let certificateChain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let pinMatched = certificateChain.contains { certificate in
            guard let publicKeyData = Self.publicKeyData(from: certificate) else { return false }
            let hash = Data(SHA256.hash(data: publicKeyData)).base64EncodedString()
            return pinnedPublicKeyHashes.contains(hash)
        }

        if pinMatched {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    private static func publicKeyData(from certificate: SecCertificate) -> Data? {
        guard let publicKey = SecCertificateCopyKey(certificate) else { return nil }
        return SecKeyCopyExternalRepresentation(publicKey, nil) as Data?
    }
}

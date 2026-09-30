import XCTest
@testable import FPLTeamViewer

final class FPLAPIClientTests: XCTestCase {
    func testHTTPFailurePreservesStatusCode() async {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [HTTPFailureProtocol.self]
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel() }

        do {
            _ = try await LiveFPLAPIClient(session: session).fetchBootstrap()
            XCTFail("Expected an HTTP error")
        } catch {
            XCTAssertEqual(error as? FPLAPIError, .httpStatus(503))
        }
    }
}

private final class HTTPFailureProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let response = HTTPURLResponse(url: request.url!, statusCode: 503, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

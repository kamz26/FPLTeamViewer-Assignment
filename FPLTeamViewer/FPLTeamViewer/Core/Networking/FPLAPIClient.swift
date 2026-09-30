import Foundation

protocol FPLAPIClient: Sendable {
    func fetchBootstrap() async throws -> BootstrapDTO
}

enum FPLAPIError: LocalizedError, Equatable {
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "The server returned an invalid response."
        case let .httpStatus(code): "The server returned HTTP \(code). Please try again."
        }
    }
}

struct LiveFPLAPIClient: FPLAPIClient {
    static let endpoint = URL(string: "https://fantasy.premierleague.com/api/bootstrap-static/")!

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchBootstrap() async throws -> BootstrapDTO {
        var request = URLRequest(url: Self.endpoint)
        request.timeoutInterval = 20
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse else { throw FPLAPIError.invalidResponse }
        guard (200...299).contains(response.statusCode) else { throw FPLAPIError.httpStatus(response.statusCode) }
        return try JSONDecoder().decode(BootstrapDTO.self, from: data)
    }
}

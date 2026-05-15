import HTTP3
import HTTP3ServiceLifecycle
import XCTest

final class HTTP3ServerServiceTests: XCTestCase {
    func testCustomStartupClosureRuns() async throws {
        let server = HTTP3Server()
        let service = HTTP3ServerService(server: server) { _ in }

        try await service.run()
    }
}
import XCTest
@testable import JSONWorkProof

final class JSONWorkProofTests: XCTestCase {
    func testExample() {
        let jwp = JWP()
        let token = try! jwp.generate(claims: ["hello": "world"])
        print(token)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

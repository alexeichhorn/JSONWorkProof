import XCTest
/*@testable */import JSONWorkProof

final class JSONWorkProofTests: XCTestCase {
    
    func testExample() {
        let jwp = JWP()
        let token = try! jwp.generate(claims: ["hello": "world"])
        print(token)
    }
    
    func testMintSHA256DefaultSpeed() {
        let jwp = JWP()
        measure {
            _ = try! jwp.generate(claims: ["test": "speedtest"])
        }
    }
    
    func testMintSHA256FastSpeed() {
        let jwp = JWP(difficulty: 15)
        measure {
            _ = try! jwp.generate(claims: ["test": "speedtest"])
        }
    }

    static var allTests = [
        ("testExample", testExample),
        ("testMintSHA256DefaultSpeed", testMintSHA256DefaultSpeed),
        ("testMintSHA256FastSpeed", testMintSHA256FastSpeed)
    ]
}

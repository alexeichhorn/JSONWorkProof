import XCTest
/*@testable */import JSONWorkProof

final class JSONWorkProofTests: XCTestCase {
    
    func testExample() {
        let jwp = JWP()
        let token = try! jwp.generate(claims: ["hello": "world"])
        print(token)
    }
    
    func generateAndCheck(on jwp: JWP, count: Int = 10) {
        for _ in 0..<count {
            let claims: [String: Codable] = [ "hello": "world", "randomInt": Int.random(in: 0..<10000000) ]
            let stamp = try? jwp.generate(claims: claims)
            
            XCTAssertNotNil(stamp)
            
            XCTAssertNoThrow(try jwp.decode(stamp!))
            guard let decodedClaims = try? jwp.decode(stamp!) else { continue }
            
            XCTAssertEqual(claims["hello"] as? String, decodedClaims["hello"] as? String)
            XCTAssertEqual(claims["randomInt"] as? String, decodedClaims["randomInt"] as? String)
        }
    }
    
    func testGenerateAndCheck() {
        generateAndCheck(on: JWP(), count: 5)
        generateAndCheck(on: JWP(difficulty: 22), count: 2)
        generateAndCheck(on: JWP(difficulty: 18), count: 5)
        generateAndCheck(on: JWP(difficulty: 15), count: 10)
        generateAndCheck(on: JWP(difficulty: 5), count: 10)
        generateAndCheck(on: JWP(difficulty: 15, saltLength: 100), count: 5)
    }
    
    // MARK: - Speedtest
    
    func testMintSHA256DefaultSpeed() {
        let jwp = JWP()
        let options = XCTMeasureOptions()
        options.iterationCount = 50
        measure(options: options) {
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

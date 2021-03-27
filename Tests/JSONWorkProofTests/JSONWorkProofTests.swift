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
    
    func testExpirationCheck() {
        let jwp = JWP(difficulty: 20)
        
        let stamp1 = "eyJ0eXAiOiJKV1AiLCJhbGciOiJTSEEyNTYiLCJkaWYiOjIwfQ.eyJleHAiOjE2MTY4NTA1NzAuNjU1MTQ3MSwiaGVsbG8iOiJ3b3JsZCJ9.VE6YYxIQ46lPzxyNuRYAmAMkEM"
        XCTAssertNoThrow(try jwp.decode(stamp1, expirationRange: .unlimited))
        XCTAssertNoThrow(try jwp.decode(stamp1, expirationRange: JWP.DateRange(start: Date(timeIntervalSince1970: 1616850383), duration: 5*60)))
        XCTAssertThrowsError(try jwp.decode(stamp1)) { error in
            XCTAssert((error as? JWP.DecodeError) == JWP.DecodeError.expired)
        }
        
        let stamp2 = "eyJ0eXAiOiJKV1AiLCJhbGciOiJTSEEyNTYiLCJkaWYiOjIwfQ.eyJoZWxsbyI6IndvcmxkIn0.LCYdFqTlHkox8chJLRoPpQB5wC" // no expiration included
        XCTAssertNoThrow(try jwp.decode(stamp2, expirationRange: .unlimited))
        XCTAssertThrowsError(try jwp.decode(stamp2)) { error in
            XCTAssert((error as? JWP.DecodeError) == JWP.DecodeError.expired)
        }
        XCTAssertThrowsError(try jwp.decode(stamp2, expirationRange: JWP.DateRange(duration: 1_000_000, end: Date()))) { error in
            XCTAssert((error as? JWP.DecodeError) == JWP.DecodeError.expired)
        }
        XCTAssertNoThrow(try jwp.decode(stamp2, expirationRange: JWP.DateRange(start: nil, end: Date())))
        
    }
    
    func testDifficultyCheck() {
        
    }
    
    
    // MARK: - Speedtest
    
    func testMintSHA256DefaultSpeed() {
        let jwp = JWP()
        let options = XCTMeasureOptions()
        //options.iterationCount = 50
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

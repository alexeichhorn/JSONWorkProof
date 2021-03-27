//
//  DateRange.swift
//  
//
//  Created by Alexander Eichhorn on 27.03.21.
//

import Foundation

extension JWP {
    
    public struct DateRange {
        
        let start: Date?
        let end: Date?
        
        public init(start: Date?, end: Date?) {
            self.start = start
            self.end = end
        }
        
        public init(start: Date, duration: TimeInterval) {
            self.init(start: start, end: start + duration)
        }
        
        public init(duration: TimeInterval, end: Date) {
            self.init(start: end - duration, end: end)
        }
        
        public static var unlimited: DateRange {
            return DateRange(start: nil, end: nil)
        }
        
        public init(fromNow duration: TimeInterval) {
            self.init(start: Date(), duration: duration)
        }
        
        
        // MARK: - Checks
        
        public func contains(_ date: Date) -> Bool {
            if let start = start, date < start {
                return false
            }
            if let end = end, date > end {
                return false
            }
            return true
        }
        
    }
    
}

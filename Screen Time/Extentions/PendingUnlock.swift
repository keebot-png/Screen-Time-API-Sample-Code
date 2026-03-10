//
//  PendingUnlock.swift
//  Screen Time
//
//  Shared storage for pending unlock requests between the Shield Action Extension and the main app.
//

import Foundation
import ManagedSettings

struct UnlockRequest: Identifiable {
    let id: String          // The storage key
    let isCategory: Bool
    let data: Data
}

/// Stores a pending unlock request in App Group UserDefaults so the main app can retrieve it.
enum PendingUnlock {
    
    private static let suiteName = "group.com.mac.Screen-Time"
    private static let pendingKey = "pendingUnlockTokens"
    
    /// Save an application token for later unlock by the main app.
    @discardableResult
    static func save(applicationToken: ApplicationToken) -> String {
        let requestID = UUID().uuidString
        guard let defaults = UserDefaults(suiteName: suiteName) else { return requestID }
        
        var pending = defaults.dictionary(forKey: pendingKey) as? [String: Data] ?? [:]
        
        if let encoded = try? JSONEncoder().encode(applicationToken) {
            pending[requestID] = encoded
            defaults.set(pending, forKey: pendingKey)
        }
        
        return requestID
    }
    
    /// Save a category token for later unlock by the main app.
    @discardableResult
    static func save(categoryToken: ActivityCategoryToken) -> String {
        let requestID = UUID().uuidString
        guard let defaults = UserDefaults(suiteName: suiteName) else { return requestID }
        
        var pending = defaults.dictionary(forKey: pendingKey) as? [String: Data] ?? [:]
        
        if let encoded = try? JSONEncoder().encode(categoryToken) {
            pending["cat:\(requestID)"] = encoded
            defaults.set(pending, forKey: pendingKey)
        }
        
        return requestID
    }
    
    /// Peek at all pending requests without removing them.
    static func allRequests() -> [UnlockRequest] {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return [] }
        let pending = defaults.dictionary(forKey: pendingKey) as? [String: Data] ?? [:]
        
        return pending.map { key, data in
            UnlockRequest(id: key, isCategory: key.hasPrefix("cat:"), data: data)
        }
    }
    
    /// Remove a single request by its key and return the decoded token.
    static func consumeApplicationToken(key: String) -> ApplicationToken? {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return nil }
        
        var pending = defaults.dictionary(forKey: pendingKey) as? [String: Data] ?? [:]
        guard let data = pending.removeValue(forKey: key) else { return nil }
        
        defaults.set(pending, forKey: pendingKey)
        return try? JSONDecoder().decode(ApplicationToken.self, from: data)
    }
    
    /// Remove a single category request by its key and return the decoded token.
    static func consumeCategoryToken(key: String) -> ActivityCategoryToken? {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return nil }
        
        var pending = defaults.dictionary(forKey: pendingKey) as? [String: Data] ?? [:]
        guard let data = pending.removeValue(forKey: key) else { return nil }
        
        defaults.set(pending, forKey: pendingKey)
        return try? JSONDecoder().decode(ActivityCategoryToken.self, from: data)
    }
    
    /// Clear all pending requests.
    static func clearAll() {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return }
        defaults.removeObject(forKey: pendingKey)
    }
}

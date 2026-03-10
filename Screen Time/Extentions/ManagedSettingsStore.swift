//
//  ManagedSettingsStore.swift
//  Screen Time
//
//  Created on 29/05/24.
//  
//

import Foundation
import FamilyControls
import ManagedSettings
import os.log

private let logger = Logger(subsystemName: "ManagedSettingsStore", category: "Settings")

extension ManagedSettingsStore {
    static var shared = ManagedSettingsStore()
    
    func shield(familyActivitySelection: FamilyActivitySelection) {
        let applicationTokens = familyActivitySelection.applicationTokens
        let categoryTokens = familyActivitySelection.categoryTokens
        
        logger.info("Applying shield — \(applicationTokens.count) app tokens, \(categoryTokens.count) category tokens")
        
        // Always use per-app shielding so we can unlock individual apps.
        // shield.applications handles individually selected apps.
        // shield.applicationCategories handles category-selected apps but as a whole unit
        // (can't remove one app from a category shield), so we use it as fallback only
        // when there are no individual app tokens.
        if !applicationTokens.isEmpty {
            shield.applications = applicationTokens
        }
        
        if !categoryTokens.isEmpty {
            if applicationTokens.isEmpty {
                // Only category tokens available — use category shielding as fallback
                shield.applicationCategories = .specific(categoryTokens)
            } else {
                // We already have app tokens, skip category-level shielding
                // since individual apps are covered by shield.applications
            }
        }
        
        logger.info("Shield applied. applications=\(String(describing: self.shield.applications?.count)), categories=\(String(describing: self.shield.applicationCategories))")
    }
}

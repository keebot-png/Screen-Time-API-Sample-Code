//
//  ShieldViewModel.swift
//  Screen Time
//
//  Created on 29/05/24.
//
//

import Foundation
import FamilyControls
import ManagedSettings
import os.log

private let logger = Logger(subsystemName: "ShieldViewModel", category: "ViewModel")

class ShieldViewModel: ObservableObject {
    @Published var familyActivitySelection = FamilyActivitySelection()
    @Published var isAuthorized = false
    @Published var isShielded = false
    @Published var pendingRequests: [UnlockRequest] = []
    
    /// Tracks categories that are currently shielded (shrinks as user unlocks).
    private var shieldedCategories: Set<ActivityCategoryToken> = []
    private let store = ManagedSettingsStore.shared
    
    var hasSelection: Bool {
        !familyActivitySelection.applicationTokens.isEmpty ||
        !familyActivitySelection.categoryTokens.isEmpty
    }
    
    func shieldActivities() {
        guard hasSelection else {
            logger.warning("No apps or categories selected — nothing to shield.")
            return
        }
        logger.info("Shielding \(self.familyActivitySelection.applicationTokens.count) apps and \(self.familyActivitySelection.categoryTokens.count) categories.")
        store.shield(familyActivitySelection: familyActivitySelection)
        shieldedCategories = familyActivitySelection.categoryTokens
        isShielded = true
    }
    
    func unshieldActivities() {
        logger.info("Removing all shields.")
        store.clearAllSettings()
        PendingUnlock.clearAll()
        shieldedCategories = []
        pendingRequests = []
        isShielded = false
    }
    
    /// Reload pending unlock requests from shared storage (non-destructive).
    func refreshPendingRequests() {
        pendingRequests = PendingUnlock.allRequests()
        logger.debug("Refreshed pending requests: \(self.pendingRequests.count) found.")
    }
    
    /// Unlock a single app/category by its request, then remove it from the list.
    func unlock(request: UnlockRequest) {
        if request.isCategory {
            if let token = PendingUnlock.consumeCategoryToken(key: request.id) {
                // Remove just this one category from the currently shielded set.
                shieldedCategories.remove(token)
                
                if shieldedCategories.isEmpty {
                    store.shield.applicationCategories = nil
                    store.shield.webDomainCategories = nil
                } else {
                    store.shield.applicationCategories = .specific(shieldedCategories)
                    store.shield.webDomainCategories = .specific(shieldedCategories)
                }
                logger.info("Unblocked category for key=\(request.id), \(self.shieldedCategories.count) categories still shielded.")
            }
        } else {
            if let token = PendingUnlock.consumeApplicationToken(key: request.id) {
                store.shield.applications?.remove(token)
                logger.info("Unblocked application for key=\(request.id)")
                
                if store.shield.applications?.isEmpty ?? false {
                    store.shield.applications = nil
                }
            }
        }
        
        // Remove from local list
        pendingRequests.removeAll { $0.id == request.id }
        
        // Update shielded state
        if store.shield.applications == nil && store.shield.applicationCategories == nil {
            isShielded = false
        }
    }
    
    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            await MainActor.run {
                isAuthorized = true
            }
            logger.info("Authorization granted.")
        } catch {
            logger.error("Failed to get authorization: \(error)")
            await MainActor.run {
                isAuthorized = false
            }
        }
    }
}

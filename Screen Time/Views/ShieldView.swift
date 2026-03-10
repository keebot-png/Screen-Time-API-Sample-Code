//
//  ShieldView.swift
//  Screen Time
//
//  Created on 29/05/24.
//
//

import SwiftUI
import FamilyControls
import ManagedSettings
import os.log

private let logger = Logger(subsystemName: "ShieldView", category: "View")

struct ShieldView: View {
    @EnvironmentObject private var manager: ShieldViewModel
    @State private var showActivityPicker = false
    
    var body: some View {
        VStack(spacing: 24) {
            if !manager.isAuthorized {
                Label("Waiting for authorization…", systemImage: "lock.shield")
                    .foregroundStyle(.secondary)
            } else {
                selectButton
                
                if manager.hasSelection {
                    Text("\(manager.familyActivitySelection.applicationTokens.count) apps and \(manager.familyActivitySelection.categoryTokens.count) categories selected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                lockButton
                
                // Pending unlock requests
                if !manager.pendingRequests.isEmpty {
                    Divider()
                    
                    Text("Unlock Requests")
                        .font(.headline)
                    
                    ForEach(manager.pendingRequests) { request in
                        HStack {
                            if request.isCategory,
                               let token = try? JSONDecoder().decode(ActivityCategoryToken.self, from: request.data) {
                                Label(token)
                                    .labelStyle(.titleAndIcon)
                            } else if !request.isCategory,
                                      let token = try? JSONDecoder().decode(ApplicationToken.self, from: request.data) {
                                Label(token)
                                    .labelStyle(.titleAndIcon)
                            } else {
                                Label("Unknown", systemImage: "app.fill")
                            }
                            
                            Spacer()
                            
                            Button {
                                manager.unlock(request: request)
                            } label: {
                                Label("Unlock", systemImage: "lock.open.fill")
                                    .font(.callout)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .familyActivityPicker(
            isPresented: $showActivityPicker,
            selection: $manager.familyActivitySelection
        )
    }
}

// MARK: Views
private extension ShieldView {
    var selectButton: some View {
        Button(action: onPressSelect) {
            Label("Select Apps", systemImage: "gearshape.fill")
        }
        .buttonStyle(.bordered)
    }
    
    var lockButton: some View {
        Button(action: onLock) {
            Label(
                manager.isShielded ? "Unlock All" : "Lock Apps",
                systemImage: manager.isShielded ? "lock.open.fill" : "lock.fill"
            )
        }
        .buttonStyle(.borderedProminent)
        .tint(manager.isShielded ? .red : .blue)
        .disabled(!manager.hasSelection)
    }
}

// MARK: Internals
private extension ShieldView {
    func onPressSelect() {
        logger.debug("Configuration button pressed.")
        showActivityPicker = true
    }
    
    func onLock() {
        if manager.isShielded {
            logger.debug("Unlock all button pressed.")
            manager.unshieldActivities()
        } else {
            logger.debug("Lock button pressed.")
            manager.shieldActivities()
        }
    }
}

#Preview {
    NavigationStack {
        ShieldView()
    }
    .environmentObject(ShieldViewModel())
}

//
//  ContentView.swift
//  Screen Time
//
//  Created on 29/05/24.
//  
//

import SwiftUI
import FamilyControls
import os.log

private let logger = Logger(subsystemName: "ContentView", category: "View")

struct ContentView: View {
    @StateObject private var manager = ShieldViewModel()
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack {
            ShieldView()
        }
        .environmentObject(manager)
        .task(id: "requestAuthorizationTaskID") {
            await manager.requestAuthorization()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                manager.refreshPendingRequests()
            }
        }
    }
}

#Preview {
    ContentView()
}

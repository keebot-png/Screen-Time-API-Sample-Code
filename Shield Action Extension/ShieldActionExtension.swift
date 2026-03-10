//
//  ShieldActionExtension.swift
//  Shield Action Extension
//
//  Created on 29/05/24.
//
//

import Foundation
import ManagedSettings
import UserNotifications
import os.log

private let logger = Logger(subsystemName: "ShieldActionExtension", category: "ShieldActionDelegate")

// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldActionExtension: ShieldActionDelegate {
    
    private func sendUnlockNotification(requestID: String, tokenType: String, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        let content = UNMutableNotificationContent()
        content.title = "Unlock Requested"
        content.body = "Tap to open the app and unlock it."
        content.sound = .default
        content.userInfo = [
            "requestID": requestID,
            "tokenType": tokenType
        ]
        
        let request = UNNotificationRequest(
            identifier: "unlock-\(requestID)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                logger.error("Failed to post unlock notification: \(error)")
            } else {
                logger.info("Unlock notification posted for requestID=\(requestID)")
            }
            completionHandler(.close)
        }
    }
    
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            let requestID = PendingUnlock.save(applicationToken: application)
            sendUnlockNotification(requestID: requestID, tokenType: "application", completionHandler: completionHandler)
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            completionHandler(.close)
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }
    
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            let requestID = PendingUnlock.save(categoryToken: category)
            sendUnlockNotification(requestID: requestID, tokenType: "category", completionHandler: completionHandler)
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }
}

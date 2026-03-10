//
//  ShieldConfigurationExtension.swift
//  Shield Configuration Extension
//
//  Created on 29/05/24.
//  
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    private func makeConfig(title: String, subtitle: String) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundColor: .systemCyan,
            title: ShieldConfiguration.Label(text: title, color: .label),
            subtitle: ShieldConfiguration.Label(text: subtitle, color: .secondaryLabel),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Request Unlock", color: .white),
            primaryButtonBackgroundColor: .systemBlue,
            secondaryButtonLabel: nil
        )
    }
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        makeConfig(
            title: "This app is locked",
            subtitle: "Tap below to request an unlock"
        )
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfig(
            title: "This app is locked",
            subtitle: "Tap below to request an unlock"
        )
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        makeConfig(
            title: "This website is locked",
            subtitle: "Tap below to request an unlock"
        )
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfig(
            title: "This website is locked",
            subtitle: "Tap below to request an unlock"
        )
    }
}

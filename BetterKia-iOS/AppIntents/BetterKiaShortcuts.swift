//
//  BetterKiaShortcuts.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 28.09.23.
//

import AppIntents

struct BetterKiaShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartPreconditioningIntent(),
            phrases: ["Start Preconditioning using \(.applicationName)"],
            systemImageName: "car.front.waves.up.fill"
        )
    }
}

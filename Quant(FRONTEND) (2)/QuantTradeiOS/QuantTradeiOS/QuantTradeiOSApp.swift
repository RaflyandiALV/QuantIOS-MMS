//
//  QuantTradeiOSApp.swift
//  QuantTradeiOS
//
//  Created by welan ale zeni on 06/12/25.
//

import SwiftUI
import CoreData

@main
struct QuantTradeiOSApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

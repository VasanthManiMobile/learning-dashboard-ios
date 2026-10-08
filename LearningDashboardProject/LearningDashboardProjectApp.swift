//
//  LearningDashboardProjectApp.swift
//  LearningDashboardProject
//
//  Created by Vasanth Mani on 08/10/26.
//

import SwiftUI
import CoreData

@main
struct LearningDashboardProjectApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

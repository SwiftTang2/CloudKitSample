//
//  NewCapApp.swift
//  NewCap
//
//  Created by 唐明华 on 2022/3/3.
//

import SwiftUI

@main
struct NewCapApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

//
//  clipboardApp.swift
//  clipboard
//
//  Created by 水月空 on 2026/4/13.
//

import SwiftUI
import SwiftData

@main
struct clipboardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ClipboardItem.self,
            Category.self,
            AppSettings.self,
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Development fallback: delete old database if schema mismatch
            let storeURL = modelConfiguration.url
            print("⚠️ Schema mismatch detected. Deleting old store at \(storeURL) to recover.")
            try? FileManager.default.removeItem(at: storeURL)
            
            // Also remove shm and wal files
            let shmURL = storeURL.deletingPathExtension().appendingPathExtension("store-shm")
            let walURL = storeURL.deletingPathExtension().appendingPathExtension("store-wal")
            try? FileManager.default.removeItem(at: shmURL)
            try? FileManager.default.removeItem(at: walURL)
            
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Still could not create ModelContainer after deleting old store: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup(id: "main") {
            ThemedContainerView {
                ContentView()
            }
        }
        .modelContainer(sharedModelContainer)

        Settings {
            ThemedContainerView {
                SettingsView()
            }
        }
        .modelContainer(sharedModelContainer)
        
        MenuBarExtra("Clipboard", systemImage: "doc.on.clipboard") {
            MenuBarExtraView()
                .modelContainer(sharedModelContainer)
        }
        .menuBarExtraStyle(.window)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            if let window = NSApplication.shared.windows.first {
                window.makeKeyAndOrderFront(nil)
            }
        }
        return true
    }
}


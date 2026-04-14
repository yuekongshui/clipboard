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
    @AppStorage("appLanguage") private var appLanguage: AppLanguage = .system
    
    static let sharedModelContainer: ModelContainer = {
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
            .environment(\.locale, appLanguage.locale ?? Locale.current)
        }
        .modelContainer(Self.sharedModelContainer)

        Settings {
            ThemedContainerView {
                SettingsView()
            }
            .environment(\.locale, appLanguage.locale ?? Locale.current)
        }
        .modelContainer(Self.sharedModelContainer)
    }
}

struct PopoverRootView: View {
    @AppStorage("appLanguage") private var appLanguage: AppLanguage = .system
    
    var body: some View {
        MenuBarExtraView()
            .environment(\.locale, appLanguage.locale ?? Locale.current)
            .modelContainer(clipboardApp.sharedModelContainer)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var popoverMonitor: Any?

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
        
        setupPopover()
        
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeKey(_:)), name: NSWindow.didBecomeKeyNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(windowWillClose(_:)), name: NSWindow.willCloseNotification, object: nil)
    }
    
    func setupPopover() {
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 350, height: 450)
        popover.behavior = .transient
        
        let contentView = PopoverRootView()
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    @objc func windowDidBecomeKey(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window.level == .normal {
            NSApp.setActivationPolicy(.regular)
        }
    }
    
    @objc func windowWillClose(_ notification: Notification) {
        let visibleWindows = NSApplication.shared.windows.filter { $0.isVisible && $0.level == .normal && $0 != notification.object as? NSWindow }
        if visibleWindows.isEmpty {
            NSApp.setActivationPolicy(.accessory)
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            if let window = NSApplication.shared.windows.first {
                window.makeKeyAndOrderFront(nil)
                NSApp.setActivationPolicy(.regular)
            }
        }
        return true
    }
}


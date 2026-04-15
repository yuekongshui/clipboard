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
        Window("Clipboard", id: "main") {
            ThemedContainerView {
                ContentView()
            }
            .environment(\.locale, appLanguage.locale ?? Locale.current)
        }
        .modelContainer(Self.sharedModelContainer)
        .commands {
            CommandGroup(replacing: .newItem) { } // 禁用 "New Window" 菜单项，确保单窗口
        }

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

@MainActor
final class TerminationController {
    static let shared = TerminationController()
    private var allowTermination = false
    
    func requestTermination() {
        allowTermination = true
    }
    
    func consumeTerminationRequest() -> Bool {
        defer { allowTermination = false }
        return allowTermination
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var popoverMonitor: Any?

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupPopover()

        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if TerminationController.shared.consumeTerminationRequest() {
            return .terminateNow
        }
        return .terminateCancel
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
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            if let window = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "main" || $0.title == "Clipboard" }) {
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
        return true
    }
}

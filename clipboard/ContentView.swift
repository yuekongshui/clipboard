//
//  ContentView.swift
//  clipboard
//
//  Created by 水月空 on 2026/4/13.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("isSettingsOpen") private var isSettingsOpen = false

    var body: some View {
        RootSplitView()
            .disabled(isSettingsOpen)
            .opacity(isSettingsOpen ? 0.8 : 1.0)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [ClipboardItem.self, Category.self, AppSettings.self], inMemory: true)
}

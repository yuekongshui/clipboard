//
//  ContentView.swift
//  clipboard
//
//  Created by 水月空 on 2026/4/13.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        RootSplitView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [ClipboardItem.self, Category.self, AppSettings.self], inMemory: true)
}

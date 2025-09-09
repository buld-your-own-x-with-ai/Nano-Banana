//
//  ContentView.swift
//  NanoBanana
//
//  Created by i on 2025/9/9.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("gemini_api_key") private var apiKey = ""
    @State private var isAPIKeySetup = false
    @StateObject private var imageGenerationViewModel = ImageGenerationViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if isAPIKeySetup && !apiKey.isEmpty {
                TabView(selection: $selectedTab) {
                    ImageGenerationView(viewModel: imageGenerationViewModel)
                        .tabItem {
                            Image(systemName: "wand.and.stars")
                            Text("生成")
                        }
                        .tag(0)
                    
                    ExampleGalleryView(
                        imageGenerationViewModel: imageGenerationViewModel,
                        selectedTab: $selectedTab
                    )
                        .tabItem {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text("案例")
                        }
                        .tag(1)
                    
                    AdvancedFeaturesView(viewModel: imageGenerationViewModel)
                        .tabItem {
                            Image(systemName: "wand.and.stars.inverse")
                            Text("高级")
                        }
                        .tag(2)
                    
                    SettingsView(apiKey: $apiKey, isSetup: $isAPIKeySetup)
                        .tabItem {
                            Image(systemName: "gear")
                            Text("设置")
                        }
                        .tag(3)
                }
            } else {
                APIKeySetupView(apiKey: $apiKey, isSetup: $isAPIKeySetup)
            }
        }
        .onAppear {
            isAPIKeySetup = !apiKey.isEmpty
            if !apiKey.isEmpty {
                imageGenerationViewModel.setupService(apiKey: apiKey)
            }
        }
        .onChange(of: apiKey) { newValue in
            if !newValue.isEmpty {
                imageGenerationViewModel.setupService(apiKey: newValue)
            }
        }
    }
}

#Preview {
    ContentView()
}

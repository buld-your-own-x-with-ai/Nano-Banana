//
//  SettingsView.swift
//  NanoBanana
//
//  Created by CodeBuddy on 2025/9/9.
//

import SwiftUI

struct SettingsView: View {
    @Binding var apiKey: String
    @Binding var isSetup: Bool
    @State private var showingAPIKeyAlert = false
    @State private var newAPIKey = ""
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundColor(.orange)
                            Text("API 密钥")
                                .font(.headline)
                        }
                        
                        Text("当前已设置 API 密钥")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button("更改 API 密钥") {
                            newAPIKey = apiKey
                            showingAPIKeyAlert = true
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("关于 Nano Banana") {
                    HStack {
                        Image(systemName: "info.circle")
                        VStack(alignment: .leading, spacing: 4) {
                            Text("版本")
                                .font(.subheadline)
                            Text("1.0.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "brain.head.profile")
                        VStack(alignment: .leading, spacing: 4) {
                            Text("AI 模型")
                                .font(.subheadline)
                            Text("Gemini 2.5 Flash Image Preview")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("功能特性") {
                    FeatureRow(
                        icon: "text.bubble",
                        title: "Text-to-Image",
                        description: "根据文本描述生成高质量图片"
                    )
                    
                    FeatureRow(
                        icon: "photo.badge.plus",
                        title: "图片编辑",
                        description: "基于输入图片进行修改和优化"
                    )
                    
                    FeatureRow(
                        icon: "arrow.triangle.2.circlepath",
                        title: "迭代优化",
                        description: "通过对话逐步完善图片效果"
                    )
                    
                    FeatureRow(
                        icon: "textformat",
                        title: "文本渲染",
                        description: "生成包含清晰文本的图片"
                    )
                    
                    FeatureRow(
                        icon: "photo.on.rectangle.angled",
                        title: "精选案例",
                        description: "68个精选案例，涵盖各种应用场景"
                    )
                }
                
                Section {
                    Button("重置应用") {
                        apiKey = ""
                        isSetup = false
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("设置")
            .alert("更改 API 密钥", isPresented: $showingAPIKeyAlert) {
                TextField("API 密钥", text: $newAPIKey)
                Button("取消", role: .cancel) { }
                Button("保存") {
                    apiKey = newAPIKey
                }
            } message: {
                Text("请输入新的 Gemini API 密钥")
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    SettingsView(apiKey: .constant("test-key"), isSetup: .constant(true))
}
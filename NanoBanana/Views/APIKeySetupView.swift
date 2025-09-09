//
//  APIKeySetupView.swift
//  NanoBanana
//
//  Created by CodeBuddy on 2025/9/9.
//

import SwiftUI

struct APIKeySetupView: View {
    @Binding var apiKey: String
    @Binding var isSetup: Bool
    @State private var inputKey = ""
    @State private var showingTutorial = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Nano Banana")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("使用 Gemini AI 生成精美图像")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("设置 API 密钥")
                        .font(.headline)
                    
                    SecureField("输入您的 Gemini API 密钥", text: $inputKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("您可以在 Google AI Studio 获取免费的 API 密钥")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 12) {
                    Button(action: setupAPI) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("开始使用")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(inputKey.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(inputKey.isEmpty)
                    
                    Button("查看使用教程") {
                        showingTutorial = true
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingTutorial) {
                TutorialView(isPresented: $showingTutorial)
            }
        }
    }
    
    private func setupAPI() {
        apiKey = inputKey
        isSetup = true
    }
}

#Preview {
    APIKeySetupView(apiKey: .constant(""), isSetup: .constant(false))
}
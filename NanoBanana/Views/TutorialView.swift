//
//  TutorialView.swift
//  NanoBanana
//
//  Created by CodeBuddy on 2025/9/9.
//

import SwiftUI

struct TutorialView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    private let pages = [
        TutorialPage(
            title: "欢迎使用 Nano Banana",
            description: "使用 Gemini 2.5 Flash 的强大 AI 图像生成功能",
            icon: "🍌",
            color: .orange
        ),
        TutorialPage(
            title: "Text-to-Image",
            description: "输入文字描述，AI 将为您生成精美的图像",
            icon: "✨",
            color: .blue
        ),
        TutorialPage(
            title: "图像编辑",
            description: "上传图片并用文字指令进行编辑和修改",
            icon: "🎨",
            color: .green
        ),
        TutorialPage(
            title: "精选案例",
            description: "浏览 68 个精选案例，学习最佳实践",
            icon: "📚",
            color: .purple
        )
    ]
    
    var body: some View {
        VStack {
            // 页面指示器
            HStack {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(currentPage == index ? Color.primary : Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: currentPage)
                }
            }
            .padding(.top)
            
            // 内容
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    TutorialPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // 按钮
            HStack {
                if currentPage > 0 {
                    Button("上一页") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if currentPage < pages.count - 1 {
                    Button("下一页") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .foregroundColor(.blue)
                } else {
                    Button("开始使用") {
                        isPresented = false
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
}

struct TutorialPageView: View {
    let page: TutorialPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text(page.icon)
                .font(.system(size: 80))
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
    }
}

struct TutorialPage {
    let title: String
    let description: String
    let icon: String
    let color: Color
}

#Preview {
    TutorialView(isPresented: .constant(true))
}
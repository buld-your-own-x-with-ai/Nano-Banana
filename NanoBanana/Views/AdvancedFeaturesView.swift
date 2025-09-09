//
//  AdvancedFeaturesView.swift
//  NanoBanana
//
//  Created by CodeBuddy on 2025/9/9.
//

import SwiftUI

struct AdvancedFeaturesView: View {
    @ObservedObject var viewModel: ImageGenerationViewModel
    @State private var batchPrompts: String = ""
    @State private var iterativePrompts: String = ""
    @State private var showingBatchSheet = false
    @State private var showingIterativeSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 批量生成卡片
                    FeatureCard(
                        title: "批量生成",
                        description: "一次性生成多张图像",
                        icon: "square.grid.3x3",
                        color: .blue
                    ) {
                        showingBatchSheet = true
                    }
                    
                    // 迭代编辑卡片
                    FeatureCard(
                        title: "迭代编辑",
                        description: "多轮对话式图像优化",
                        icon: "arrow.triangle.2.circlepath",
                        color: .green
                    ) {
                        showingIterativeSheet = true
                    }
                    
                    // 缓存管理卡片
                    CacheManagementCard(viewModel: viewModel)
                    
                    // 使用技巧
                    UsageTipsCard()
                }
                .padding()
            }
            .navigationTitle("高级功能")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingBatchSheet) {
            BatchGenerationSheet(viewModel: viewModel, prompts: $batchPrompts)
        }
        .sheet(isPresented: $showingIterativeSheet) {
            IterativeEditingSheet(viewModel: viewModel, prompts: $iterativePrompts)
        }
    }
}

struct FeatureCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CacheManagementCard: View {
    @ObservedObject var viewModel: ImageGenerationViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "externaldrive")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                Text("缓存管理")
                    .font(.headline)
                
                Spacer()
            }
            
            HStack {
                Text("缓存大小:")
                    .foregroundColor(.secondary)
                
                Text(viewModel.getCacheSize())
                    .fontWeight(.medium)
                
                Spacer()
                
                Button("清理缓存") {
                    viewModel.clearImageCache()
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .foregroundColor(.orange)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct UsageTipsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                Text("使用技巧")
                    .font(.headline)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                TipRow(text: "提示词要具体明确，避免模糊描述")
                TipRow(text: "图像大小控制在4MB以内")
                TipRow(text: "使用缓存可以节省API调用次数")
                TipRow(text: "批量处理适合生成相似风格的图像")
                TipRow(text: "迭代编辑可以逐步完善图像效果")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct TipRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.yellow)
                .fontWeight(.bold)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

struct BatchGenerationSheet: View {
    @ObservedObject var viewModel: ImageGenerationViewModel
    @Binding var prompts: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("批量生成图像")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("每行输入一个提示词，最多支持10个")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextEditor(text: $prompts)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .frame(minHeight: 200)
                
                if viewModel.isBatchProcessing {
                    VStack(spacing: 8) {
                        ProgressView(value: viewModel.batchProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                        
                        Text("处理中... \(Int(viewModel.batchProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: {
                    let promptList = prompts.components(separatedBy: .newlines)
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                        .prefix(10)
                    
                    Task {
                        await viewModel.batchGenerateImages(prompts: Array(promptList))
                        dismiss()
                    }
                }) {
                    Text(viewModel.isBatchProcessing ? "生成中..." : "开始批量生成")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(prompts.isEmpty || viewModel.isBatchProcessing ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(prompts.isEmpty || viewModel.isBatchProcessing)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct IterativeEditingSheet: View {
    @ObservedObject var viewModel: ImageGenerationViewModel
    @Binding var prompts: String
    @Environment(\.dismiss) private var dismiss
    @State private var initialPrompt = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("迭代编辑")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("初始提示词")
                        .font(.headline)
                    
                    TextField("描述要生成的初始图像", text: $initialPrompt)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("编辑步骤")
                        .font(.headline)
                    
                    Text("每行输入一个编辑指令，将按顺序执行")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $prompts)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .frame(minHeight: 150)
                }
                
                Button(action: {
                    let editPrompts = prompts.components(separatedBy: .newlines)
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    
                    Task {
                        await viewModel.iterativeImageEditing(
                            initialPrompt: initialPrompt,
                            editPrompts: editPrompts
                        )
                        dismiss()
                    }
                }) {
                    Text(viewModel.isGenerating ? "生成中..." : "开始迭代编辑")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(initialPrompt.isEmpty || viewModel.isGenerating ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(initialPrompt.isEmpty || viewModel.isGenerating)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AdvancedFeaturesView(viewModel: ImageGenerationViewModel())
}
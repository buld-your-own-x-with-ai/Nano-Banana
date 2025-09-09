//
//  ExampleGalleryView.swift
//  NanoBanana
//
//  Created by CodeBuddy on 2025/9/9.
//

import SwiftUI

struct ExampleGalleryView: View {
    let imageGenerationViewModel: ImageGenerationViewModel
    @Binding var selectedTab: Int
    @State private var selectedExample: NanoBananaExample?
    @State private var searchText = ""
    
    private let examples = NanoBananaExample.allExamples
    
    var body: some View {
        NavigationView {
            VStack {
                // 搜索栏
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                // 示例列表
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredExamples, id: \.id) { example in
                            ExampleCard(example: example) {
                                selectedExample = example
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("精选案例")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedExample) { example in
                ExampleDetailView(
                    example: example,
                    imageGenerationViewModel: imageGenerationViewModel,
                    selectedTab: $selectedTab
                )
            }
        }
    }
    
    private var filteredExamples: [NanoBananaExample] {
        if searchText.isEmpty {
            return examples
        } else {
            return examples.filter { example in
                example.title.localizedCaseInsensitiveContains(searchText) ||
                example.prompt.localizedCaseInsensitiveContains(searchText) ||
                example.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("搜索案例...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct ExampleCard: View {
    let example: NanoBananaExample
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(example.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Text("by \(example.author)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(example.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
                
                Text(example.prompt)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                if !example.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(example.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(4)
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ExampleDetailView: View {
    let example: NanoBananaExample
    let imageGenerationViewModel: ImageGenerationViewModel
    @Binding var selectedTab: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 标题和作者
                    VStack(alignment: .leading, spacing: 8) {
                        Text(example.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("by \(example.author)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(example.category)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                    }
                    
                    Divider()
                    
                    // 提示词
                    VStack(alignment: .leading, spacing: 8) {
                        Text("提示词")
                            .font(.headline)
                        
                        Text(example.prompt)
                            .font(.body)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // 使用说明
                    if !example.instructions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("使用说明")
                                .font(.headline)
                            
                            Text(example.instructions)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // 标签
                    if !example.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("标签")
                                .font(.headline)
                            
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 80))
                            ], spacing: 8) {
                                ForEach(example.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("案例详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("应用") {
                        imageGenerationViewModel.applyPrompt(example.prompt)
                        selectedTab = 0 // 切换到生成页面
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ExampleGalleryView(
        imageGenerationViewModel: ImageGenerationViewModel(),
        selectedTab: .constant(1)
    )
}
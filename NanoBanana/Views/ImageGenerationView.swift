//
//  ImageGenerationView.swift
//  NanoBanana
//
//  Created by CodeBuddy on 2025/9/9.
//

import SwiftUI
import PhotosUI

struct ImageGenerationView: View {
    @ObservedObject var viewModel: ImageGenerationViewModel
    @State private var showingImagePicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingSuggestions = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 输入区域
                inputSection
                
                Divider()
                
                // 生成的图像列表
                imageListSection
            }
            .navigationTitle("Nano Banana")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var inputSection: some View {
        VStack(spacing: 16) {
            // 输入图像选择
            if let inputImage = viewModel.selectedInputImage {
                HStack {
                    Image(uiImage: inputImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    VStack(alignment: .leading) {
                        Text("输入图像")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("点击更换图像")
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    Button("移除") {
                        viewModel.selectedInputImage = nil
                    }
                    .foregroundColor(.red)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .onTapGesture {
                    showingImagePicker = true
                }
            } else {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                        Text("添加输入图像（可选）")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            
            // 文本提示输入
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("描述您想要生成的图像")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button("示例") {
                        showingSuggestions.toggle()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                
                TextField("例如：一只可爱的橙色小猫在花园里玩耍", text: $viewModel.currentPrompt, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
                
                if showingSuggestions {
                    PromptSuggestionsView { prompt in
                        viewModel.currentPrompt = prompt
                        showingSuggestions = false
                    }
                    .frame(height: 200)
                }
            }
            
            // 生成按钮
            Button(action: {
                Task {
                    await viewModel.generateImage()
                }
            }) {
                HStack {
                    if viewModel.isGenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "wand.and.stars")
                    }
                    Text(viewModel.isGenerating ? "生成中..." : "生成图像")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.currentPrompt.isEmpty || viewModel.isGenerating ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(viewModel.currentPrompt.isEmpty || viewModel.isGenerating)
            
            // 错误信息
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
        }
        .padding()
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let newItem = newItem,
                   let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.selectedInputImage = image
                }
            }
        }
    }
    
    private var imageListSection: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.generatedImages) { generatedImage in
                    ImageCard(generatedImage: generatedImage, viewModel: viewModel)
                }
            }
            .padding()
        }
    }
}

struct ImageCard: View {
    let generatedImage: GeneratedImage
    let viewModel: ImageGenerationViewModel
    @State private var showingFullScreen = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 图像
            Image(uiImage: generatedImage.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(12)
                .onTapGesture {
                    showingFullScreen = true
                }
            
            // 提示文本
            Text(generatedImage.prompt)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            // 时间和操作
            HStack {
                Text(generatedImage.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    viewModel.saveImageToPhotos(generatedImage.image)
                }) {
                    Image(systemName: "square.and.arrow.down")
                }
                
                Button(action: {
                    viewModel.deleteImage(generatedImage)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .fullScreenCover(isPresented: $showingFullScreen) {
            FullScreenImageView(image: generatedImage.image)
        }
    }
}

struct FullScreenImageView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZoomableImageView(image: image)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("完成") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct ZoomableImageView: UIViewRepresentable {
    let image: UIImage
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        let imageView = UIImageView(image: image)
        
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 3.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollView.subviews.first
        }
    }
}

#Preview {
    ImageGenerationView(viewModel: ImageGenerationViewModel())
}
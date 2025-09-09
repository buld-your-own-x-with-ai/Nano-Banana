//
//  ImageGenerationViewModel.swift
//  NanoBanana
//
//  Created by CodeBuddy on 2025/9/9.
//

import Foundation
import UIKit
import SwiftUI

@MainActor
class ImageGenerationViewModel: ObservableObject {
    @Published var generatedImages: [GeneratedImage] = []
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var currentPrompt = ""
    @Published var selectedInputImage: UIImage?
    @Published var isBatchProcessing = false
    @Published var batchProgress: Double = 0.0
    
    private var geminiService: GeminiService?
    
    func setupService(apiKey: String) {
        geminiService = GeminiService(apiKey: apiKey)
    }
    
    func generateImage() async {
        guard !currentPrompt.isEmpty else { return }
        guard let service = geminiService else {
            errorMessage = "请先设置 API 密钥"
            return
        }
        
        isGenerating = true
        errorMessage = nil
        
        do {
            let image = try await service.generateImage(
                prompt: currentPrompt,
                inputImage: selectedInputImage
            )
            
            let generatedImage = GeneratedImage(
                id: UUID(),
                image: image,
                prompt: currentPrompt,
                inputImage: selectedInputImage,
                createdAt: Date()
            )
            
            generatedImages.insert(generatedImage, at: 0)
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isGenerating = false
    }
    
    func deleteImage(_ image: GeneratedImage) {
        generatedImages.removeAll { $0.id == image.id }
    }
    
    func saveImageToPhotos(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func applyPrompt(_ prompt: String) {
        currentPrompt = prompt
    }
    
    // MARK: - 批量处理
    func batchGenerateImages(prompts: [String]) async {
        guard let service = geminiService else {
            errorMessage = "请先设置 API 密钥"
            return
        }
        
        isBatchProcessing = true
        batchProgress = 0.0
        errorMessage = nil
        
        do {
            let images = try await service.batchGenerateImages(prompts: prompts)
            
            for (index, image) in images.enumerated() {
                let generatedImage = GeneratedImage(
                    id: UUID(),
                    image: image,
                    prompt: prompts[index],
                    inputImage: selectedInputImage,
                    createdAt: Date()
                )
                generatedImages.insert(generatedImage, at: 0)
                
                // 更新进度
                batchProgress = Double(index + 1) / Double(prompts.count)
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isBatchProcessing = false
        batchProgress = 0.0
    }
    
    // MARK: - 迭代编辑
    func iterativeImageEditing(initialPrompt: String, editPrompts: [String]) async {
        guard let service = geminiService else {
            errorMessage = "请先设置 API 密钥"
            return
        }
        
        isGenerating = true
        errorMessage = nil
        
        do {
            let images = try await service.iterativeImageEditing(
                initialPrompt: initialPrompt,
                editPrompts: editPrompts,
                inputImage: selectedInputImage
            )
            
            // 添加初始图像
            let initialImage = GeneratedImage(
                id: UUID(),
                image: images[0],
                prompt: initialPrompt,
                inputImage: selectedInputImage,
                createdAt: Date()
            )
            generatedImages.insert(initialImage, at: 0)
            
            // 添加编辑后的图像
            for (index, image) in images.dropFirst().enumerated() {
                let editedImage = GeneratedImage(
                    id: UUID(),
                    image: image,
                    prompt: "编辑: \(editPrompts[index])",
                    inputImage: images[index],
                    createdAt: Date()
                )
                generatedImages.insert(editedImage, at: 0)
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isGenerating = false
    }
    
    // MARK: - 缓存管理
    func clearImageCache() {
        ImageCache.shared.clearCache()
    }
    
    func getCacheSize() -> String {
        let bytes = ImageCache.shared.getCacheSize()
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Models
struct GeneratedImage: Identifiable, Equatable {
    let id: UUID
    let image: UIImage
    let prompt: String
    let inputImage: UIImage?
    let createdAt: Date
    
    static func == (lhs: GeneratedImage, rhs: GeneratedImage) -> Bool {
        lhs.id == rhs.id
    }
}
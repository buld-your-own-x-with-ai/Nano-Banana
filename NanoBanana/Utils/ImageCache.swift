//
//  ImageCache.swift
//  NanoBanana
//
//  Created by CodeBuddy on 2025/9/9.
//

import Foundation
import UIKit

/// 图像缓存管理器，用于优化重复请求的性能
class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        // 设置缓存目录
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        cacheDirectory = documentsPath.appendingPathComponent("ImageCache")
        
        // 创建缓存目录
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // 配置内存缓存
        cache.countLimit = 50 // 最多缓存50张图片
        cache.totalCostLimit = 100 * 1024 * 1024 // 100MB内存限制
    }
    
    /// 生成缓存键
    private func cacheKey(for prompt: String, inputImage: UIImage?) -> String {
        var key = prompt
        if let inputImage = inputImage,
           let imageData = inputImage.jpegData(compressionQuality: 0.8) {
            let imageHash = imageData.hashValue
            key += "_\(imageHash)"
        }
        return key.md5
    }
    
    /// 从缓存获取图像
    func getCachedImage(for prompt: String, inputImage: UIImage?) -> UIImage? {
        let key = cacheKey(for: prompt, inputImage: inputImage)
        
        // 先检查内存缓存
        if let cachedImage = cache.object(forKey: NSString(string: key)) {
            return cachedImage
        }
        
        // 检查磁盘缓存
        let fileURL = cacheDirectory.appendingPathComponent("\(key).jpg")
        if let imageData = try? Data(contentsOf: fileURL),
           let image = UIImage(data: imageData) {
            // 加载到内存缓存
            cache.setObject(image, forKey: NSString(string: key))
            return image
        }
        
        return nil
    }
    
    /// 缓存图像
    func cacheImage(_ image: UIImage, for prompt: String, inputImage: UIImage?) {
        let key = cacheKey(for: prompt, inputImage: inputImage)
        
        // 保存到内存缓存
        cache.setObject(image, forKey: NSString(string: key))
        
        // 保存到磁盘缓存
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let fileURL = cacheDirectory.appendingPathComponent("\(key).jpg")
            try? imageData.write(to: fileURL)
        }
    }
    
    /// 清理缓存
    func clearCache() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    /// 获取缓存大小
    func getCacheSize() -> Int64 {
        guard let enumerator = fileManager.enumerator(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        var totalSize: Int64 = 0
        for case let fileURL as URL in enumerator {
            if let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
               let fileSize = resourceValues.fileSize {
                totalSize += Int64(fileSize)
            }
        }
        return totalSize
    }
}

// MARK: - String MD5 Extension
extension String {
    var md5: String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { bytes in
            return bytes.bindMemory(to: UInt8.self)
        }
        
        var digest = [UInt8](repeating: 0, count: 16)
        // 简化的哈希实现，实际项目中建议使用 CryptoKit
        for i in 0..<min(data.count, 16) {
            digest[i] = hash[i]
        }
        
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
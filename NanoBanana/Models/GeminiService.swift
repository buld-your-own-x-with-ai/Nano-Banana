//
//  GeminiService.swift
//  NanoBanana
//
//  Created by CodeBuddy on 2025/9/9.
//

import Foundation
import UIKit

class GeminiService: ObservableObject {
    private let apiKey: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image-preview:generateContent"
    
    // 速率限制相关
    private var lastRequestTime: Date = Date.distantPast
    private let minRequestInterval: TimeInterval = 1.0 // 最小请求间隔1秒
    
    // 图像大小限制 (4MB)
    private let maxImageSize: Int = 4 * 1024 * 1024
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func generateImage(prompt: String, inputImage: UIImage? = nil) async throws -> UIImage {
        // 输入验证
        try validateInput(prompt: prompt, inputImage: inputImage)
        
        // 检查缓存
        if let cachedImage = ImageCache.shared.getCachedImage(for: prompt, inputImage: inputImage) {
            print("从缓存返回图像")
            return cachedImage
        }
        
        // 速率限制
        try await enforceRateLimit()
        
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        
        let requestBody = createRequestBody(prompt: prompt, inputImage: inputImage)
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw GeminiError.invalidRequest
        }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            // 网络错误处理
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    throw GeminiError.networkError
                case .timedOut:
                    throw GeminiError.rateLimitExceeded
                default:
                    throw GeminiError.networkError
                }
            }
            throw GeminiError.networkError
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }
        
        // 打印调试信息
        print("HTTP Status Code: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response: \(responseString)")
        }
        
        // 详细的HTTP状态码处理
        switch httpResponse.statusCode {
        case 200:
            break // 成功，继续处理
        case 400:
            if let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorResponse["error"] as? [String: Any],
               let message = error["message"] as? String {
                if message.contains("API key") {
                    throw GeminiError.invalidAPIKey
                } else {
                    throw GeminiError.apiError(message)
                }
            }
            throw GeminiError.invalidRequest
        case 401:
            throw GeminiError.invalidAPIKey
        case 429:
            throw GeminiError.rateLimitExceeded
        case 403:
            if let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorResponse["error"] as? [String: Any],
               let message = error["message"] as? String,
               message.contains("quota") {
                throw GeminiError.quotaExceeded
            }
            throw GeminiError.invalidAPIKey
        case 500...599:
            throw GeminiError.invalidResponse
        default:
            if let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorResponse["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw GeminiError.apiError(message)
            }
            throw GeminiError.invalidResponse
        }
        
        // 打印完整响应用于调试
        if let responseString = String(data: data, encoding: .utf8) {
            print("Complete API Response: \(responseString)")
        }
        
        let geminiResponse: GeminiResponse
        do {
            geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
            print("✅ JSON 解析成功")
        } catch {
            print("❌ JSON 解析失败: \(error)")
            throw GeminiError.invalidResponse
        }
        
        print("候选结果数量: \(geminiResponse.candidates.count)")
        
        guard let candidate = geminiResponse.candidates.first else {
            print("❌ 没有找到候选结果")
            throw GeminiError.noImageGenerated
        }
        
        print("内容部分数量: \(candidate.content.parts.count)")
        
        // 打印所有部分的详细信息
        for (index, p) in candidate.content.parts.enumerated() {
            print("部分 \(index): text=\(p.text != nil ? "存在文本" : "nil"), inlineData=\(p.inlineData != nil ? "存在图像数据" : "nil")")
            if let text = p.text {
                print("  📝 文本内容: \(text)")
            }
            if let inlineData = p.inlineData {
                print("  🖼️ 图像数据: MIME=\(inlineData.mimeType), 长度=\(inlineData.data.count)")
            }
        }
        
        // 查找包含图像数据的部分
        guard let imagePart = candidate.content.parts.first(where: { $0.inlineData != nil }) else {
            print("❌ 在所有部分中都没有找到内联数据")
            throw GeminiError.noImageGenerated
        }
        
        guard let inlineData = imagePart.inlineData else {
            print("❌ 没有找到内联数据")
            throw GeminiError.noImageGenerated
        }
        
        print("✅ 找到内联数据")
        print("MIME 类型: \(inlineData.mimeType)")
        print("Base64 数据长度: \(inlineData.data.count)")
        
        guard let imageData = Data(base64Encoded: inlineData.data) else {
            print("❌ Base64 解码失败")
            print("Base64 数据前100字符: \(String(inlineData.data.prefix(100)))")
            throw GeminiError.invalidImageFormat
        }
        
        print("✅ Base64 解码成功，数据大小: \(imageData.count) 字节")
        
        guard let image = UIImage(data: imageData) else {
            print("❌ UIImage 创建失败")
            throw GeminiError.invalidImageFormat
        }
        
        print("✅ UIImage 创建成功，尺寸: \(image.size)")
        
        // 缓存生成的图像
        ImageCache.shared.cacheImage(image, for: prompt, inputImage: inputImage)
        
        return image
    }
    
    private func createRequestBody(prompt: String, inputImage: UIImage?) -> [String: Any] {
        var parts: [[String: Any]] = []
        
        // 根据是否有输入图像来构建不同的提示
        if let inputImage = inputImage {
            // 图像编辑模式
            let imageData = inputImage.jpegData(compressionQuality: 0.8)!
            let base64Image = imageData.base64EncodedString()
            
            parts.append([
                "inline_data": [
                    "mime_type": "image/jpeg",
                    "data": base64Image
                ]
            ])
            parts.append(["text": prompt])
        } else {
            // 纯文本生成图像模式
            parts.append(["text": prompt])
        }
        
        // 添加安全设置
        let safetySettings = [
            [
                "category": "HARM_CATEGORY_HATE_SPEECH",
                "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            ],
            [
                "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
                "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            ],
            [
                "category": "HARM_CATEGORY_HARASSMENT",
                "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            ],
            [
                "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
                "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            ]
        ]
        
        return [
            "contents": [
                [
                    "parts": parts
                ]
            ],
            "safetySettings": safetySettings
        ]
    }
    
    // MARK: - 输入验证
    private func validateInput(prompt: String, inputImage: UIImage?) throws {
        // 验证提示词
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw GeminiError.invalidRequest
        }
        
        guard prompt.count <= 2000 else {
            throw GeminiError.promptTooLong
        }
        
        // 验证图像大小
        if let inputImage = inputImage {
            guard let imageData = inputImage.jpegData(compressionQuality: 0.8) else {
                throw GeminiError.invalidImageFormat
            }
            
            guard imageData.count <= maxImageSize else {
                throw GeminiError.imageTooLarge
            }
        }
    }
    
    // MARK: - 速率限制
    private func enforceRateLimit() async throws {
        let now = Date()
        let timeSinceLastRequest = now.timeIntervalSince(lastRequestTime)
        
        if timeSinceLastRequest < minRequestInterval {
            let waitTime = minRequestInterval - timeSinceLastRequest
            try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
        }
        
        lastRequestTime = Date()
    }
    
    // MARK: - 批量处理
    /// 批量生成图像
    func batchGenerateImages(prompts: [String], inputImages: [UIImage?] = []) async throws -> [UIImage] {
        guard !prompts.isEmpty else {
            throw GeminiError.invalidRequest
        }
        
        var results: [UIImage] = []
        let maxPrompts = min(prompts.count, inputImages.isEmpty ? prompts.count : inputImages.count)
        
        for i in 0..<maxPrompts {
            let prompt = prompts[i]
            let inputImage = i < inputImages.count ? inputImages[i] : nil
            
            do {
                let image = try await generateImage(prompt: prompt, inputImage: inputImage)
                results.append(image)
            } catch {
                print("批量处理第\(i+1)个请求失败: \(error.localizedDescription)")
                // 继续处理下一个，不中断整个批量操作
                continue
            }
        }
        
        return results
    }
    
    /// 多轮对话式图像编辑
    func iterativeImageEditing(initialPrompt: String, editPrompts: [String], inputImage: UIImage? = nil) async throws -> [UIImage] {
        var results: [UIImage] = []
        var currentImage = inputImage
        
        // 第一轮：初始生成
        let firstImage = try await generateImage(prompt: initialPrompt, inputImage: currentImage)
        results.append(firstImage)
        currentImage = firstImage
        
        // 后续轮次：基于前一轮结果进行编辑
        for editPrompt in editPrompts {
            let editedImage = try await generateImage(prompt: editPrompt, inputImage: currentImage)
            results.append(editedImage)
            currentImage = editedImage
        }
        
        return results
    }
}

// MARK: - Response Models
struct GeminiResponse: Codable {
    let candidates: [Candidate]
}

struct Candidate: Codable {
    let content: Content
}

struct Content: Codable {
    let parts: [Part]
}

struct Part: Codable {
    let text: String?
    let inlineData: InlineData?
    
    enum CodingKeys: String, CodingKey {
        case text
        case inlineData
    }
}

struct InlineData: Codable {
    let mimeType: String
    let data: String
    
    enum CodingKeys: String, CodingKey {
        case mimeType
        case data
    }
}

// MARK: - Errors
enum GeminiError: Error, LocalizedError {
    case invalidResponse
    case noImageGenerated
    case invalidAPIKey
    case invalidRequest
    case apiError(String)
    case promptTooLong
    case imageTooLarge
    case invalidImageFormat
    case rateLimitExceeded
    case quotaExceeded
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "服务器响应无效"
        case .noImageGenerated:
            return "未能生成图像，请尝试不同的提示词"
        case .invalidAPIKey:
            return "API 密钥无效，请检查设置"
        case .invalidRequest:
            return "请求格式无效，请检查输入内容"
        case .apiError(let message):
            return "API 错误: \(message)"
        case .promptTooLong:
            return "提示词过长，请控制在2000字符以内"
        case .imageTooLarge:
            return "图像文件过大，请选择小于4MB的图像"
        case .invalidImageFormat:
            return "不支持的图像格式，请使用JPEG或PNG格式"
        case .rateLimitExceeded:
            return "请求过于频繁，请稍后再试"
        case .quotaExceeded:
            return "API 配额已用完，请检查账户状态"
        case .networkError:
            return "网络连接错误，请检查网络设置"
        }
    }
}

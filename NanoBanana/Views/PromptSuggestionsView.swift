//
//  PromptSuggestionsView.swift
//  NanoBanana
//
//  Created by CodeBuddy on 2025/9/9.
//

import SwiftUI

struct PromptSuggestionsView: View {
    let onPromptSelected: (String) -> Void
    @State private var selectedCategory: PromptCategory = .creative
    
    private let suggestions = [
        // 基础创意类
        PromptSuggestion(
            title: "可爱动物",
            prompt: "一只可爱的橙色小猫在花园里玩耍，阳光透过树叶洒在它身上",
            icon: "🐱",
            category: .creative
        ),
        PromptSuggestion(
            title: "科幻场景",
            prompt: "未来城市的夜景，霓虹灯闪烁，飞行汽车在空中穿梭",
            icon: "🚀",
            category: .creative
        ),
        PromptSuggestion(
            title: "自然风光",
            prompt: "宁静的湖泊倒映着雪山，湖边有粉色的樱花盛开",
            icon: "🌸",
            category: .creative
        ),
        
        // 产品设计类
        PromptSuggestion(
            title: "产品摄影",
            prompt: "一张高分辨率的摄影棚级商品照片，展示的是一个简约的陶瓷咖啡杯，采用工作室灯光，放置在抛光的混凝土表面上",
            icon: "📷",
            category: .product
        ),
        PromptSuggestion(
            title: "Logo设计",
            prompt: "为一家名为'The Daily Grind'的咖啡店设计一个现代简约的徽标。文字应采用简洁、粗体、无衬线字体。设计应包含一个简单、风格化的咖啡豆图标，与文字无缝融合。配色方案为黑白色",
            icon: "🏷️",
            category: .product
        ),
        PromptSuggestion(
            title: "包装设计",
            prompt: "精美的日式料理摆盘，在温暖的灯光下显得格外诱人，专业美食摄影",
            icon: "📦",
            category: .product
        ),
        
        // 艺术风格类
        PromptSuggestion(
            title: "水彩画风格",
            prompt: "一幅水彩画风格的樱花树，粉色花瓣飘落，柔和的色彩渐变，艺术感强烈",
            icon: "🎨",
            category: .artistic
        ),
        PromptSuggestion(
            title: "油画风格",
            prompt: "梵高风格的星空下的小镇，旋转的笔触和鲜艳的色彩，充满表现力的艺术作品",
            icon: "🖼️",
            category: .artistic
        ),
        PromptSuggestion(
            title: "极简设计",
            prompt: "一幅极简主义构图，画面中只有一片精致的红枫叶位于画面右下角。背景是大片空白的米白色画布，为文字创造了大量负空间。柔和的漫射光线从左上方照射",
            icon: "⚪",
            category: .artistic
        ),
        
        // 实用功能类
        PromptSuggestion(
            title: "信息图表",
            prompt: "制作一张关于地球上最甜蜜事物的彩色信息图，加上丰富可爱的卡通人物和元素",
            icon: "📊",
            category: .functional
        ),
        PromptSuggestion(
            title: "漫画风格",
            prompt: "一张采用粗犷的黑色电影艺术风格的漫画书单格画面，高对比度的黑白墨水。前景中，一个穿着风衣的侦探站在闪烁的路灯下，雨水浸湿了他的肩膀",
            icon: "💭",
            category: .functional
        ),
        PromptSuggestion(
            title: "贴纸设计",
            prompt: "一张可爱风格的贴纸，上面是一只快乐的小熊猫戴着小竹帽，正在啃绿色的竹叶。设计采用粗体、干净的轮廓，简单的赛璐珞阴影和鲜艳的调色板。背景必须是白色",
            icon: "🏷️",
            category: .functional
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 分类选择器
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PromptCategory.allCases, id: \.self) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            // 建议卡片
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(filteredSuggestions, id: \.title) { suggestion in
                        SuggestionCard(suggestion: suggestion) {
                            onPromptSelected(suggestion.prompt)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private var filteredSuggestions: [PromptSuggestion] {
        suggestions.filter { $0.category == selectedCategory }
    }
}

struct SuggestionCard: View {
    let suggestion: PromptSuggestion
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(suggestion.icon)
                        .font(.title2)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(suggestion.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Text(suggestion.prompt)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategoryButton: View {
    let category: PromptCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(category.icon)
                    .font(.caption)
                Text(category.title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

enum PromptCategory: CaseIterable {
    case creative, product, artistic, functional
    
    var title: String {
        switch self {
        case .creative: return "创意"
        case .product: return "产品"
        case .artistic: return "艺术"
        case .functional: return "实用"
        }
    }
    
    var icon: String {
        switch self {
        case .creative: return "✨"
        case .product: return "📦"
        case .artistic: return "🎨"
        case .functional: return "🔧"
        }
    }
}

struct PromptSuggestion {
    let title: String
    let prompt: String
    let icon: String
    let category: PromptCategory
}

#Preview {
    PromptSuggestionsView { prompt in
        print("Selected prompt: \(prompt)")
    }
}
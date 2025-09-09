//
//  NanoBananaExample.swift
//  NanoBanana
//
//  Created by CodeBuddy on 2025/9/9.
//

import Foundation

struct NanoBananaExample: Identifiable {
    let id = UUID()
    let title: String
    let prompt: String
    let author: String
    let category: String
    let instructions: String
    let tags: [String]
    
    static let allExamples: [NanoBananaExample] = [
        // 创意设计类
        NanoBananaExample(
            title: "插画变手办",
            prompt: "将这张照片变成角色手办。在它后面放置一个印有角色图像的盒子，盒子上有一台电脑显示Blender建模过程。在盒子前面添加一个圆形塑料底座，角色手办站在上面。如果可能的话，将场景设置在室内",
            author: "@ZHO_ZHO_ZHO",
            category: "创意设计",
            instructions: "需上传一张参考图片作为生成手办的对象",
            tags: ["手办", "3D建模", "角色设计", "产品设计"]
        ),
        
        NanoBananaExample(
            title: "乐高玩具小人",
            prompt: "将照片中的人物转化为乐高小人包装盒的风格，以等距透视呈现。在包装盒上标注标题\"ZHOGUE\"。在盒内展示基于照片中人物的乐高小人，并配有他们必需的物品（如化妆品、包或其他物品）作为乐高配件。在盒子旁边，也展示实际乐高小人本身，未包装，以逼真且生动的方式渲染。",
            author: "@ZHO_ZHO_ZHO",
            category: "创意设计",
            instructions: "需上传一张参考图像",
            tags: ["乐高", "玩具设计", "包装设计", "等距视角"]
        ),
        
        // 图像编辑类
        NanoBananaExample(
            title: "自动修图",
            prompt: "这张照片很无聊很平淡。增强它！增加对比度，提升色彩，改善光线使其更丰富，你可以裁剪和删除影响构图的细节",
            author: "@op7418",
            category: "图像编辑",
            instructions: "需上传一张需要进行修正的图像",
            tags: ["修图", "色彩增强", "构图优化", "光线调整"]
        ),
        
        NanoBananaExample(
            title: "旧照片上色",
            prompt: "修复并为这张照片上色",
            author: "@GeminiApp",
            category: "图像编辑",
            instructions: "需上传一张老旧、需要修复的照片",
            tags: ["照片修复", "上色", "历史照片", "图像恢复"]
        ),
        
        // 风格转换类
        NanoBananaExample(
            title: "动漫转真人Coser",
            prompt: "生成一个女孩cosplay这张插画的照片，背景设置在Comiket",
            author: "@ZHO_ZHO_ZHO",
            category: "风格转换",
            instructions: "需上传一张插画图像",
            tags: ["Cosplay", "动漫", "真人化", "角色扮演"]
        ),
        
        NanoBananaExample(
            title: "漫画风格转换",
            prompt: "将输入的图片处理为黑白漫画风格线稿",
            author: "@nobisiro_2023",
            category: "风格转换",
            instructions: "需上传一张参考图像",
            tags: ["漫画", "线稿", "黑白", "艺术风格"]
        ),
        
        // 产品设计类
        NanoBananaExample(
            title: "精致可爱的产品照片",
            prompt: "一张高分辨率广告照片，一位男士用拇指和食指精心握着一件逼真的微型产品。背景干净清爽，摄影棚灯光，阴影柔和。手部造型精致，肤色自然，摆放位置凸显了产品的形状和细节。产品看起来极小，但细节丰富，品牌形象精准，位于画面中央，景深浅。模仿了奢侈品摄影和极简主义商业风格。",
            author: "@azed_ai",
            category: "产品设计",
            instructions: "将[方括号]中的文字改为需要展示的产品",
            tags: ["产品摄影", "广告", "微型", "商业摄影"]
        ),
        
        NanoBananaExample(
            title: "珠宝首饰设计",
            prompt: "将这张图像变成一条包含5件首饰的系列。",
            author: "@Gdgtify",
            category: "产品设计",
            instructions: "需上传一张参考图像",
            tags: ["珠宝设计", "首饰", "系列设计", "奢侈品"]
        ),
        
        // 实用功能类
        NanoBananaExample(
            title: "根据食材做菜",
            prompt: "用这些食材为我做一顿美味的午餐，放在盘子里，盘子的特写视图，移除其他盘子和食材",
            author: "@Gdgtify",
            category: "实用功能",
            instructions: "需上传一张带有多种食材的照片",
            tags: ["美食", "食谱", "烹饪", "食材搭配"]
        ),
        
        NanoBananaExample(
            title: "数学题推理",
            prompt: "根据问题将问题的答案写在对应的位置上",
            author: "@Gorden Sun",
            category: "实用功能",
            instructions: "需上传一道数学类的题目",
            tags: ["数学", "解题", "教育", "推理"]
        ),
        
        NanoBananaExample(
            title: "食物卡路里标注",
            prompt: "用食物名称、卡路里密度和近似卡路里来注释这顿饭",
            author: "@icreatelife",
            category: "实用功能",
            instructions: "需上传一张食物参考图像",
            tags: ["营养分析", "卡路里", "健康", "食物标注"]
        ),
        
        // 艺术创作类
        NanoBananaExample(
            title: "定制大理石雕塑",
            prompt: "一张超详细的图像中主体雕塑的写实图像，由闪亮的大理石制成。雕塑应展示光滑反光的大理石表面，强调其光泽和艺术工艺。设计优雅，突出大理石的美丽和深度。图像中的光线应增强雕塑的轮廓和纹理，创造出视觉上令人惊叹和迷人的效果",
            author: "@umesh_ai",
            category: "艺术创作",
            instructions: "需上传一张参考图像",
            tags: ["雕塑", "大理石", "艺术", "古典风格"]
        ),
        
        NanoBananaExample(
            title: "印刷插画生成",
            prompt: "仅使用短语\"riding a bike\"中的字母，创作一幅极简主义的黑白印刷插图，描绘骑自行车的场景。每个字母的形状和位置都应富有创意，以构成骑车人、自行车和动感。设计应简洁、极简，完全由修改后的\"riding a bike\"字母组成，不添加任何额外的形状或线条。",
            author: "@Umesh",
            category: "艺术创作",
            instructions: "将[方括号]中的文字改为需要的文字",
            tags: ["字体设计", "极简主义", "创意排版", "黑白艺术"]
        ),
        
        // 场景生成类
        NanoBananaExample(
            title: "根据地图箭头生成地面视角图片",
            prompt: "从红色圆圈沿箭头方向画出真实世界的视角",
            author: "@tokumin",
            category: "场景生成",
            instructions: "需要上传一张包含红色箭头的google maps图像",
            tags: ["地图", "街景", "视角转换", "地理"]
        ),
        
        NanoBananaExample(
            title: "Google地图视角下的中土世界",
            prompt: "行车记录仪谷歌街景拍摄 | 霍比屯街道 | 霍比特人进行园艺和抽烟斗等日常活动 | 晴天",
            author: "@TechHallo",
            category: "场景生成",
            instructions: "将[方括号]中的文字改为需要的地区和天气",
            tags: ["奇幻", "街景", "霍比特人", "中土世界"]
        ),
        
        // 人物编辑类
        NanoBananaExample(
            title: "更换多种发型",
            prompt: "以九宫格的方式生成这个人不同发型的头像",
            author: "@balconychy",
            category: "人物编辑",
            instructions: "需上传一张需要更换发型的人像图片",
            tags: ["发型设计", "人像编辑", "九宫格", "造型"]
        ),
        
        NanoBananaExample(
            title: "虚拟试妆",
            prompt: "为图一人物化上图二的妆，还保持图一的姿势",
            author: "@ZHO_ZHO_ZHO",
            category: "人物编辑",
            instructions: "需上传一张人物参考图像和一张妆造参考图片",
            tags: ["化妆", "美妆", "试妆", "人像美化"]
        ),
        
        NanoBananaExample(
            title: "制作证件照",
            prompt: "截取图片人像头部，帮我做成2寸证件照，要求: 1、蓝底 2、职业正装 3、正脸 4、微笑",
            author: "@songguoxiansen",
            category: "人物编辑",
            instructions: "需上传一张人物参考图像",
            tags: ["证件照", "正装", "蓝底", "职业照"]
        )
    ]
}
# Clipboard

[English](README.en.md) | 简体中文 | [日本語](README.ja.md)

一个基于 **Swift + SwiftUI + SwiftData** 的本地剪切板管理 macOS 应用。

## 核心功能

* **多类型支持**：支持文本、图片、文件等多类型内容的管理。
* **历史记录管理**：自动监听系统剪切板变化，保存历史记录，并支持重新复制使用。
* **快速检索与筛选**：支持关键词搜索，以及按内容类型、分类、收藏状态进行多维度组合筛选。
* **分类与收藏**：支持自定义分类管理（新建、编辑、删除），可将高频使用的记录标记为收藏。
* **隐私保护**：支持敏感内容自动过滤（密码、Token、验证码等）和应用黑名单配置。

## 技术栈

* **运行平台**：macOS 14+
* **开发语言**：Swift
* **UI 框架**：SwiftUI
* **数据持久化**：SwiftData

## 架构设计

项目采用清晰的分层架构（MVVM + Service）：
* **Models**：数据模型层，包括剪切板记录 (`ClipboardItem`)、分类 (`Category`) 和全局设置 (`AppSettings`)。
* **Services**：业务逻辑层，包含剪切板监听 (`ClipboardMonitorService`)、数据持久化 (`ClipboardStorageService`)、文件存储 (`FileStorageService`) 和隐私过滤 (`PrivacyFilterService`)。
* **ViewModels**：视图模型层，负责状态管理和视图逻辑处理。
* **Views**：视图层，采用 macOS 原生的三栏结构 (`NavigationSplitView`) 设计。

## 数据隐私与安全

* **完全本地化**：所有历史记录和业务数据仅保存在本地设备，无任何网络依赖和云同步行为。
* **敏感信息保护**：对疑似敏感文本默认采取“拦截不保存”的保守策略。
* **大文件存储优化**：图片仅保存至本地目录并记录路径，避免数据库膨胀；文件仅保存引用路径，不复制实体文件。

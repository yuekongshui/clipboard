# clipboard开发文档（SRS + SwiftData 模型设计 + SwiftUI 页面结构）

## 项目背景

本项目是一个基于 **Swift + SwiftUI + SwiftData** 的本地剪切板管理应用，当前仅支持 **本地存储**，不包含云同步、账号体系、多设备同步等能力。

核心目标如下：

* 支持文本、图片、文件等多类型内容管理
* 支持历史记录管理
* 支持快速检索
* 支持分类筛选
* 支持分类收藏
* 支持隐私保护

---

# 一、开发用 SRS

## 1. 引言

### 1.1 目的

本文档用于定义一款本地剪切板管理应用的软件需求，供产品、设计、开发、测试共同使用。
系统目标是实现对剪切板历史内容的本地采集、存储、检索、分类、收藏与隐私保护。

### 1.2 范围

本系统为本地运行的剪切板管理工具，支持以下核心能力：

* 自动监听剪切板变化
* 保存文本、图片、文件三类内容
* 按类型、分类、收藏状态筛选
* 支持关键词搜索
* 支持收藏与分类管理
* 支持隐私保护与敏感内容过滤
* 所有数据仅本地存储

本期不包含：

* iCloud/云同步
* 多设备同步
* 登录账号
* OCR
* 团队共享

### 1.3 术语定义

* **剪切板记录**：用户一次复制操作形成的一条历史记录
* **分类**：用户用于管理记录的逻辑分组
* **收藏**：用户标记为高频复用的记录
* **敏感内容**：疑似密码、验证码、Token、私钥等不宜长期保存的内容
* **来源应用**：复制内容时的前台应用名

---

## 2. 总体描述

### 2.1 产品目标

本系统用于解决系统原生剪切板无法查看历史、无法搜索、无法分类管理的问题。

### 2.2 用户特征

目标用户包括：

* 开发者
* 办公人员
* 编辑与写作者
* 设计师
* 高频复制粘贴用户

### 2.3 运行环境

* 平台：macOS
* 语言：Swift
* UI：SwiftUI
* 数据持久化：SwiftData
* 存储方式：本地持久化，无网络依赖

### 2.4 设计约束

* 所有核心功能应离线可用
* 所有历史记录仅保存在本地
* UI 必须支持浅色/深色模式
* 功能实现优先稳定与可维护，不以过度优化为第一目标

---

## 3. 功能性需求

## 3.1 剪切板监听

### FR-001 剪切板变化监听

系统应在应用运行期间持续监听系统剪切板变化。
当剪切板内容发生变化时，系统应触发内容解析流程。

**输入**
用户执行复制操作。

**输出**
一条待处理的剪切板内容对象。

**约束**

* 系统不得因读取失败导致崩溃
* 未识别类型可忽略
* 应避免同一轮轮询重复入库

### FR-002 内容类型识别

系统应识别以下内容类型：

* 文本
* 图片
* 文件/文件夹引用

### FR-003 去重控制

系统应支持基础去重。
当新内容与最近一条记录在“内容摘要 + 类型”上相同，且复制时间间隔小于设定阈值时，可不重复保存。

### FR-004 来源应用采集

系统应尽可能记录复制发生时的前台应用名称，用于筛选与黑名单判断。

---

## 3.2 历史记录管理

### FR-005 保存历史记录

系统应在内容识别通过且隐私策略允许后，将记录保存至本地数据库。

### FR-006 历史列表展示

系统应按时间倒序展示剪切板记录。

列表项至少显示：

* 类型图标
* 预览摘要
* 创建时间
* 收藏状态
* 分类名称

### FR-007 记录详情查看

用户选中记录后，系统应展示完整详情。

* 文本：显示全文
* 图片：显示大图预览
* 文件：显示文件名、路径、类型

### FR-008 删除单条记录

用户应可删除单条历史记录。

### FR-009 批量删除记录

用户应可批量删除多条记录。

### FR-010 清空历史记录

用户应可执行“清空全部历史”操作。
系统应提供二次确认。

### FR-011 自动清理

系统应支持按规则自动清理历史记录：

* 最大条数限制
* 保存天数限制

**规则**

* 收藏记录默认不优先清理
* 敏感记录若允许入库，应支持更短保留期

---

## 3.3 搜索与筛选

### FR-012 关键词搜索

系统应支持对历史记录进行关键词搜索。

搜索范围：

* 文本内容
* 预览摘要
* 文件名
* 文件路径
* 分类名称
* 来源应用名

### FR-013 类型筛选

用户应可按以下类型筛选：

* 全部
* 文本
* 图片
* 文件

### FR-014 分类筛选

用户应可按分类筛选记录。

### FR-015 收藏筛选

用户应可筛选：

* 全部
* 仅收藏
* 仅未收藏

### FR-016 组合筛选

系统应支持关键词、类型、分类、收藏状态的组合筛选。

---

## 3.4 收藏与分类

### FR-017 收藏切换

用户应可将任意记录标记为收藏或取消收藏。

### FR-018 分类分配

用户应可为记录指定分类。

### FR-019 分类管理

系统应支持分类管理：

* 新建分类
* 修改分类名称
* 删除分类

### FR-020 分类删除规则

删除分类时，不得删除其下记录。
原记录应自动转移到“未分类”。

---

## 3.5 复用操作

### FR-021 再次复制

用户点击某条记录时，系统应可将该记录重新写入系统剪切板。

### FR-022 记录使用时间

当用户执行再次复制后，系统应更新该记录的 `lastUsedAt`。

### FR-023 文件记录复用

文件类记录再次复制时，应恢复为文件引用，而不是复制文件实体。

### FR-024 图片记录复用

图片类记录再次复制时，应恢复为图片数据。

---

## 3.6 隐私保护

### FR-025 敏感文本识别

系统应支持对文本内容进行敏感信息识别。

首期至少识别以下模式：

* 密码类字段
* 验证码样式文本
* Token/API Key 样式文本
* 私钥片段
* 银行卡号样式文本
* 身份证号样式文本

### FR-026 敏感内容默认策略

检测为敏感内容的文本，默认不入库。

### FR-027 黑名单应用

系统应支持配置应用黑名单。
来自黑名单应用的剪切板内容不应被保存。

### FR-028 本地隐私约束

系统不得主动上传任何剪切板数据到外部网络服务。

---

## 3.7 设置

### FR-029 通用设置

系统应支持以下设置项：

* 是否启用监听
* 是否启用去重
* 最大历史记录数
* 自动清理天数
* 是否启用敏感过滤
* 黑名单应用列表
* 是否显示图片缩略图

### FR-030 数据管理设置

系统应支持：

* 清空数据库
* 导出配置（后续可扩展）
* 重建默认分类（可选）

---

## 4. 非功能性需求

## 4.1 性能

### NFR-001 监听延迟

剪切板变化后，系统应在可接受时间内完成识别与保存，正常情况下不应产生明显延迟感。

### NFR-002 列表流畅性

在常规规模历史记录下，主列表滚动与切换应保持流畅。

### NFR-003 搜索响应

用户输入关键词后，搜索结果应快速刷新，不出现明显卡顿。

---

## 4.2 稳定性

### NFR-004 异常容错

读取剪切板失败、图片解码失败、文件路径失效等情况不得导致应用崩溃。

### NFR-005 数据完整性

应用异常退出后，已成功保存的数据应可恢复读取。

---

## 4.3 安全性

### NFR-006 本地存储

所有业务数据必须仅保存在本地。

### NFR-007 敏感信息保守处理

对疑似敏感文本，默认采取“拦截不保存”的保守策略。

---

## 4.4 可维护性

### NFR-008 架构分层

系统应按以下职责分层实现：

* Clipboard 监听层
* 解析与隐私过滤层
* 持久化层
* 业务服务层
* SwiftUI 表现层

### NFR-009 模块解耦

UI 层不得直接包含复杂剪切板解析逻辑；解析与保存应通过服务层统一处理。

---

## 5. 外部接口需求

## 5.1 系统接口

系统需要与 macOS 剪切板交互，支持读取和写入：

* 文本
* 图片
* 文件 URL

## 5.2 UI 交互接口

系统应提供以下主要交互入口：

* 侧边栏分类选择
* 顶部搜索栏
* 类型筛选器
* 历史记录列表
* 详情面板
* 设置页

---

## 6. 数据需求

### 6.1 实体

系统至少包含以下实体：

* ClipboardItem
* Category
* AppSettings

### 6.2 数据关系

* 一个 Category 对应多个 ClipboardItem
* 一个 ClipboardItem 至多属于一个 Category
* AppSettings 为全局单例型配置对象

---

## 7. 业务规则

### BR-001 默认分类

系统首次启动时，应自动创建“未分类”。

### BR-002 收藏清理优先级

自动清理时，收藏记录应低优先级删除。

### BR-003 删除分类转移规则

删除分类时，其下记录迁移到“未分类”。

### BR-004 文件路径失效处理

若文件记录对应路径已失效，列表仍保留历史记录，但详情中应标记“原文件不可用”。

### BR-005 搜索与筛选并行生效

当用户同时设置关键词、类型和分类时，查询结果取交集。

---

## 8. 验收标准

满足以下条件即可认为版本可交付：

1. 能自动保存文本、图片、文件三类剪切板记录
2. 能展示历史记录列表和详情
3. 能再次复制某条历史记录
4. 能按关键词搜索文本和文件信息
5. 能按类型、分类、收藏状态筛选
6. 能新建、编辑、删除分类
7. 能收藏和取消收藏记录
8. 能识别并拦截敏感文本
9. 能配置黑名单应用并阻止其内容入库
10. 全部数据仅本地保存

---

# 二、直接对应 SwiftData 的数据模型设计

## 1. 枚举设计

```swift
import Foundation

enum ClipboardContentType: String, Codable, CaseIterable {
    case text
    case image
    case file
}

enum FavoriteFilter: String, CaseIterable {
    case all
    case favoriteOnly
    case nonFavoriteOnly
}

enum AutoCleanStrategy: String, Codable {
    case none
    case byCount
    case byDays
    case mixed
}
```

---

## 2. ClipboardItem 模型

### 2.1 设计原则

因为 SwiftData 对复杂联合类型建模时，拆字段会更稳定，所以建议一个总表承载三类内容，按类型决定哪些字段生效，而不是做三张继承表。

### 2.2 字段设计

```swift
import Foundation
import SwiftData

@Model
final class ClipboardItem {
    var id: UUID
    var typeRawValue: String

    // 通用字段
    var previewText: String
    var createdAt: Date
    var updatedAt: Date
    var lastUsedAt: Date?
    var sourceAppName: String?
    var isFavorite: Bool
    var isSensitive: Bool
    var isDeleted: Bool

    // 文本类型
    var textContent: String?

    // 图片类型
    var imageLocalPath: String?
    var imageWidth: Double?
    var imageHeight: Double?

    // 文件类型
    var filePath: String?
    var fileName: String?
    var fileUTI: String?
    var fileSize: Int64?

    // 分类
    var category: Category?

    init(
        id: UUID = UUID(),
        type: ClipboardContentType,
        previewText: String,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        lastUsedAt: Date? = nil,
        sourceAppName: String? = nil,
        isFavorite: Bool = false,
        isSensitive: Bool = false,
        isDeleted: Bool = false,
        textContent: String? = nil,
        imageLocalPath: String? = nil,
        imageWidth: Double? = nil,
        imageHeight: Double? = nil,
        filePath: String? = nil,
        fileName: String? = nil,
        fileUTI: String? = nil,
        fileSize: Int64? = nil,
        category: Category? = nil
    ) {
        self.id = id
        self.typeRawValue = type.rawValue
        self.previewText = previewText
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastUsedAt = lastUsedAt
        self.sourceAppName = sourceAppName
        self.isFavorite = isFavorite
        self.isSensitive = isSensitive
        self.isDeleted = isDeleted
        self.textContent = textContent
        self.imageLocalPath = imageLocalPath
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.filePath = filePath
        self.fileName = fileName
        self.fileUTI = fileUTI
        self.fileSize = fileSize
        self.category = category
    }
}
```

### 2.3 扩展属性

```swift
extension ClipboardItem {
    var type: ClipboardContentType {
        get { ClipboardContentType(rawValue: typeRawValue) ?? .text }
        set { typeRawValue = newValue.rawValue }
    }
}
```

### 2.4 字段说明

核心字段建议这样使用：

* `previewText`：列表展示摘要，不直接依赖全文生成，便于性能控制
* `textContent`：仅文本类型有效
* `imageLocalPath`：保存图片文件到本地目录，只在数据库里存路径
* `filePath`：保存原文件引用路径
* `sourceAppName`：用于黑名单和筛选
* `isSensitive`：即使未来允许敏感内容入库，也能单独标记
* `isDeleted`：保留软删除扩展空间；首期可不启用

### 2.5 存储建议

不要把大图片直接塞进模型字段里。
建议做法：

* 文本：直接入库
* 图片：保存到 `Application Support/ClipboardImages/`，数据库只存路径
* 文件：只保存文件路径和元数据，不复制实体文件

---

## 3. Category 模型

```swift
import Foundation
import SwiftData

@Model
final class Category {
    var id: UUID
    var name: String
    var iconName: String?
    var colorHex: String?
    var createdAt: Date

    @Relationship(deleteRule: .nullify, inverse: \ClipboardItem.category)
    var items: [ClipboardItem]

    init(
        id: UUID = UUID(),
        name: String,
        iconName: String? = nil,
        colorHex: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.items = []
    }
}
```

### 3.1 设计说明

* 删除分类时使用 `.nullify`，然后业务层再把这些记录转移到“未分类”
* `iconName` 可以直接用 SF Symbols 名称
* `colorHex` 用于 SwiftUI 展示分类色

---

## 4. AppSettings 模型

首期如果设置项不多，也可以先用 `@AppStorage`。
但既然希望结构统一，建议仍然建一个全局设置模型。

```swift
import Foundation
import SwiftData

@Model
final class AppSettings {
    var id: UUID

    var isMonitoringEnabled: Bool
    var isDeduplicationEnabled: Bool
    var isSensitiveFilterEnabled: Bool
    var maxHistoryCount: Int
    var autoCleanDays: Int
    var autoCleanStrategyRawValue: String

    // 展示设置
    var isImageThumbnailEnabled: Bool

    // 黑名单应用，以换行或分隔符存储，首期够用
    var blacklistedAppsRawValue: String

    init(
        id: UUID = UUID(),
        isMonitoringEnabled: Bool = true,
        isDeduplicationEnabled: Bool = true,
        isSensitiveFilterEnabled: Bool = true,
        maxHistoryCount: Int = 500,
        autoCleanDays: Int = 30,
        autoCleanStrategy: AutoCleanStrategy = .mixed,
        isImageThumbnailEnabled: Bool = true,
        blacklistedAppsRawValue: String = ""
    ) {
        self.id = id
        self.isMonitoringEnabled = isMonitoringEnabled
        self.isDeduplicationEnabled = isDeduplicationEnabled
        self.isSensitiveFilterEnabled = isSensitiveFilterEnabled
        self.maxHistoryCount = maxHistoryCount
        self.autoCleanDays = autoCleanDays
        self.autoCleanStrategyRawValue = autoCleanStrategy.rawValue
        self.isImageThumbnailEnabled = isImageThumbnailEnabled
        self.blacklistedAppsRawValue = blacklistedAppsRawValue
    }
}
```

扩展属性：

```swift
extension AppSettings {
    var autoCleanStrategy: AutoCleanStrategy {
        get { AutoCleanStrategy(rawValue: autoCleanStrategyRawValue) ?? .mixed }
        set { autoCleanStrategyRawValue = newValue.rawValue }
    }

    var blacklistedApps: [String] {
        get {
            blacklistedAppsRawValue
                .split(separator: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        set {
            blacklistedAppsRawValue = newValue.joined(separator: "\n")
        }
    }
}
```

---

## 5. 查询模型建议

为了避免把查询条件散在多个 View 里，建议单独做一个查询状态对象。

```swift
import Foundation

struct ClipboardQueryState {
    var keyword: String = ""
    var selectedType: ClipboardContentType? = nil
    var selectedCategoryID: UUID? = nil
    var favoriteFilter: FavoriteFilter = .all
}
```

业务层根据这个状态生成查询条件，而不是让 View 到处拼 Predicate。

---

## 6. Repository / Service 层建议

### 6.1 ClipboardMonitorService

职责：

* 监听剪切板变化
* 解析内容类型
* 读取来源应用
* 调用隐私过滤
* 调用持久化

### 6.2 ClipboardStorageService

职责：

* 新增记录
* 删除记录
* 批量删除
* 自动清理
* 再次复制到系统剪切板

### 6.3 PrivacyFilterService

职责：

* 敏感内容识别
* 黑名单应用判断

### 6.4 CategoryService

职责：

* 新建分类
* 修改分类
* 删除分类并迁移记录

---

# 三、SwiftUI 页面结构说明

这里按一个标准的 macOS 三栏或双栏结构来设计，尽量贴近 SwiftUI 的实现方式。

---

## 1. 页面总览

建议页面树如下：

```text
App
└── RootSplitView
    ├── SidebarView
    ├── HistoryListView
    └── DetailView
```

再加一个独立的：

```text
SettingsScene
└── SettingsView
```

---

## 2. RootSplitView

### 2.1 作用

作为应用主容器，承载：

* 左侧分类与筛选入口
* 中间历史记录列表
* 右侧详情面板

### 2.2 推荐实现

在 macOS 上建议优先使用：

```swift
NavigationSplitView
```

推荐三栏结构：

* `sidebar`：分类、收藏、筛选入口
* `content`：历史记录列表
* `detail`：详情面板

### 2.3 持有状态

根视图建议持有：

* 当前关键词
* 当前类型筛选
* 当前分类
* 当前收藏筛选
* 当前选中记录 ID

---

## 3. SidebarView

### 3.1 功能

显示导航与筛选入口。

### 3.2 内容结构

建议包括以下区块：

#### 区块一：快捷入口

* 全部记录
* 收藏记录
* 最近使用
* 敏感拦截统计（可后续扩展）

#### 区块二：类型筛选

* 文本
* 图片
* 文件

#### 区块三：分类列表

* 未分类
* 用户创建的分类

#### 区块四：分类管理按钮

* 新建分类
* 编辑分类
* 删除分类

### 3.3 交互规则

* 点击分类或类型后，更新列表查询条件
* 删除分类时弹确认框
* 当前选中项应有高亮状态

---

## 4. HistoryListView

### 4.1 功能

展示符合当前筛选条件的记录列表。

### 4.2 顶部结构

建议顶部区域包括：

* 搜索框
* 类型 SegmentedControl / Picker
* 收藏筛选控件
* 排序方式控件（首期可先固定为时间倒序）

### 4.3 列表项结构

建议抽成 `ClipboardRowView`。

每一行包含：

* 类型图标
* 标题/摘要
* 次级信息（时间、来源应用、分类）
* 收藏标记
* 敏感标记（若未来允许入库）
* 快捷操作菜单

### 4.4 行级操作

建议支持右键菜单或 trailing 操作：

* 复制
* 收藏 / 取消收藏
* 移动到分类
* 删除

### 4.5 空状态

无数据时显示空态视图：

* 无历史记录
* 当前筛选条件下无匹配结果

---

## 5. ClipboardRowView

### 5.1 文本记录样式

显示：

* 文本图标
* 单行或双行摘要
* 时间
* 分类名

### 5.2 图片记录样式

显示：

* 缩略图
* 图片尺寸或“图片”
* 时间
* 分类名

### 5.3 文件记录样式

显示：

* 文件图标
* 文件名
* 路径摘要
* 时间
* 分类名

### 5.4 UI 设计建议

* 文本摘要最多 2 行
* 时间作为次级信息弱化展示
* 收藏星标放右上或右侧
* 图片缩略图统一固定尺寸，避免行高跳动

---

## 6. DetailView

### 6.1 功能

展示当前选中记录的完整内容与操作按钮。

### 6.2 文本详情

显示：

* 完整文本
* 来源应用
* 创建时间
* 复制按钮
* 收藏按钮
* 分类选择器
* 删除按钮

### 6.3 图片详情

显示：

* 大图预览
* 图片尺寸
* 来源应用
* 复制按钮
* 收藏按钮
* 删除按钮

### 6.4 文件详情

显示：

* 文件名
* 文件完整路径
* 文件类型
* 文件存在状态
* 复制引用按钮
* 在 Finder 中显示按钮
* 收藏按钮
* 删除按钮

### 6.5 空详情态

未选中任何记录时显示引导态：

* “选择一条记录查看详情”

---

## 7. 分类管理页面 / 弹窗

首期不一定要做独立页面，完全可以做成 Sheet。

### 7.1 CategoryEditorSheet

支持：

* 新建分类
* 编辑分类名
* 选择图标
* 选择颜色

### 7.2 删除分类交互

删除时弹确认框，并明确提示：

* 该分类下记录不会被删除
* 记录将转移到“未分类”

---

## 8. 设置页结构

建议使用独立 `SettingsView`，分 Tab 或分 Section。

### 8.1 GeneralSettingsView

内容：

* 启用监听
* 启用去重
* 最大历史条数
* 自动清理天数

### 8.2 PrivacySettingsView

内容：

* 启用敏感过滤
* 黑名单应用列表编辑
* 敏感策略说明

### 8.3 DisplaySettingsView

内容：

* 是否显示图片缩略图
* 默认列表布局
* 深色模式跟随系统说明

### 8.4 DataSettingsView

内容：

* 清空历史记录
* 清空图片缓存
* 重置默认分类

---

## 9. ViewModel 建议

虽然是 SwiftUI + SwiftData，但仍然建议加轻量 ViewModel，不要把所有动作写进 View。

建议结构：

```text
RootViewModel
├── SidebarViewModel
├── HistoryListViewModel
├── DetailViewModel
└── SettingsViewModel
```

### 9.1 RootViewModel

职责：

* 管理全局筛选条件
* 管理当前选中记录
* 协调侧边栏、列表、详情之间的状态

### 9.2 HistoryListViewModel

职责：

* 负责搜索、筛选、排序组合
* 触发删除、收藏、复制等列表动作

### 9.3 DetailViewModel

职责：

* 负责详情展示数据
* 处理复制、删除、修改分类等动作

### 9.4 SettingsViewModel

职责：

* 读取和保存 AppSettings
* 触发清空历史等危险操作

---

## 10. 页面状态流转

建议的状态流转如下：

### 10.1 新内容入库

1. `ClipboardMonitorService` 监听到变化
2. 解析内容类型
3. 隐私过滤
4. 存入 SwiftData
5. `HistoryListView` 自动刷新

### 10.2 用户检索

1. 用户输入关键词
2. 更新 `ClipboardQueryState`
3. 列表重新计算结果
4. 用户选中某条记录
5. `DetailView` 展示详情

### 10.3 用户分类管理

1. 用户创建/编辑分类
2. 分类保存到 SwiftData
3. 侧边栏自动刷新
4. 用户可将记录移动到该分类

---

## 11. 推荐文件组织结构

这是一个比较稳的目录拆分：

```text
App/
  ClipboardApp.swift

Models/
  ClipboardItem.swift
  Category.swift
  AppSettings.swift
  Enums.swift
  ClipboardQueryState.swift

Services/
  ClipboardMonitorService.swift
  ClipboardStorageService.swift
  PrivacyFilterService.swift
  FileStorageService.swift

ViewModels/
  RootViewModel.swift
  HistoryListViewModel.swift
  DetailViewModel.swift
  SettingsViewModel.swift

Views/
  Root/
    RootSplitView.swift
  Sidebar/
    SidebarView.swift
    CategoryEditorSheet.swift
  History/
    HistoryListView.swift
    ClipboardRowView.swift
  Detail/
    DetailView.swift
    TextDetailView.swift
    ImageDetailView.swift
    FileDetailView.swift
  Settings/
    SettingsView.swift
    GeneralSettingsView.swift
    PrivacySettingsView.swift
    DataSettingsView.swift

Utilities/
  NSPasteboard+Extensions.swift
  NSImage+Extensions.swift
  DateFormatter+Extensions.swift
  String+SensitiveDetect.swift
```

---

# 四、建议的首版实现顺序

## Phase 1：核心闭环

1. `ClipboardItem / Category / AppSettings` 模型建好
2. 剪切板监听文本
3. 文本记录列表 + 详情
4. 再次复制
5. 搜索
6. 收藏
7. 分类

## Phase 2：扩展类型

1. 图片监听与本地文件缓存
2. 文件引用监听与复用
3. 图片 / 文件详情页

## Phase 3：隐私与设置

1. 敏感文本识别
2. 黑名单应用
3. 自动清理
4. 设置页

---

# 五、推荐优先确定的实现决策

1. **图片只存本地路径，不直接存数据库二进制**
2. **文件只存引用路径，不复制文件**
3. **分类删除时统一迁移到未分类**
4. **敏感文本默认不入库**
5. **列表查询统一经过 QueryState + Service，不在 View 里散写逻辑**
6. **主界面直接用 NavigationSplitView 三栏结构**

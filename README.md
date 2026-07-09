# FTPay iOS App

NMI FTPay 商户端 iOS 移动支付应用，面向商户提供 NFC 收银、交易查询、API Key 管理等功能。

## 功能特性

- 🔐 **商户登录** - Email + Password 认证
- 💳 **NFC 收银** - 支持 NFC 贴卡支付
- 📜 **交易流水** - 按日期查看历史交易
- ⚙️ **商户设置** - 主题色、域名、语言配置
- 🔑 **API Key 绑定** - 多商户支持

## 页面结构

| 页面 | 文件 | 说明 |
|------|------|------|
| 登录页 | `Views/Login/LoginView.swift` | 商户登录 |
| 主页 | `Views/Home/HomeView.swift` | 商户信息、统计、最近交易 |
| 收银页 | `Views/Purchase/PurchaseView.swift` | 金额输入、NFC 贴卡 |
| 历史记录 | `Views/History/HistoryView.swift` | 按日期筛选交易流水 |
| 设置页 | `Views/Settings/SettingsView.swift` | 主题色、域名、语言 |
| API Key 绑定 | `Views/Settings/BindAPIKeyView.swift` | 绑定商户 API Key |
| 密码验证 | `Views/Settings/PasswordVerifyView.swift` | 敏感操作二次验证 |

## 技术栈

- **框架**: SwiftUI
- **最低版本**: iOS 16.0
- **支付**: CoreNFC
- **构建**: XcodeGen + GitHub Actions

## 项目构建

### 前置条件

- macOS + Xcode (或 GitHub Actions 自动构建)
- XcodeGen: `brew install xcodegen`

### 本地构建

```bash
# 安装 XcodeGen
brew install xcodegen

# 生成 Xcode 项目
xcodegen generate --project .

# 用 Xcode 打开
open FTPay.xcodeproj
```

### GitHub Actions 自动构建

Push 代码到 `main` 分支即可自动触发构建，Actions 会生成 `.ipa` 安装包。

下载构建产物:
1. 打开 GitHub 仓库 → **Actions** 页面
2. 点击最新的构建任务
3. 下载 **FTPay-unsigned.ipa** 或 **FTPay.app**

## 安装说明

### 方式一：越狱设备直接安装（推荐）

1. 下载 `FTPay.app` 构建产物
2. 通过 SFTP/SSH 将 `FTPay.app` 传到 iPhone
3. 安装：`dpkg -i com.ftsafe.ftpay_*`

### 方式二：AltStore / Sideloadly

1. 下载 `FTPay.ipa` 构建产物
2. 使用 AltStore 或 Sideloadly 签名安装

### 方式三：自签名（需 macOS）

```bash
# 1. 解压 ipa
unzip FTPay-unsigned.ipa

# 2. 重新签名（需有效的 Apple Developer 证书）
codesign -f -v "YourCertName" "Payload/FTPay.app"

# 3. 打包
zip -r FTPay-signed.ipa Payload/

# 4. 安装
xcrun simctl install booted FTPay-signed.ipa
```

## 版本信息

- **App Version**: v3.0.0
- **Build**: 2026.07.09
- **NMI SDK**: 集成 NMI Partner 平台 API

## 目录结构

```
FTPay/
├── FTPay/
│   ├── FTPayApp.swift         # App 入口
│   ├── ContentView.swift     # 根视图
│   ├── Assets.xcassets/       # 图片资源
│   ├── Models/                # 数据模型
│   ├── Views/                 # 页面视图
│   ├── Services/              # API & NFC 服务
│   └── Components/            # 可复用组件
├── project.yml                # XcodeGen 配置
└── .github/workflows/build.yml
```

# Android 安装包

| 文件 | 适用设备 |
| --- | --- |
| [DiveSea-android-arm64.apk](DiveSea-android-arm64.apk) | 常见 ARM64 Android 真机 |
| [DiveSea-android-x64.apk](DiveSea-android-x64.apk) | x86_64 Android 模拟器 |

版本 1.0.0+1，应用名 DiveSea，包名 `com.divesea.divesea`。由 `lib/main.dart` 构建的 Release 应用，不含自动化测试入口。使用开发签名供本地安装验收，未发布到应用商店。

APK 校验值见 [SHA256SUMS.txt](SHA256SUMS.txt)。本次已在 Android 15 模拟器安装并启动 x64 包；ARM64 包完成编译，未在实体手机上测试。

首次启动进入引导，可选择演示钱包或直接继续创建演示账户。本项目不会连接真实钱包或发起真实交易。

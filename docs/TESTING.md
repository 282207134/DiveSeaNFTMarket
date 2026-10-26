# 运行与验证记录

## 环境

验证日期：2026-10-27（日本时间）。

| 项目 | 环境 |
| --- | --- |
| 主机 | Windows |
| Flutter | 3.47.7 stable |
| Dart | 3.13.5 |
| Android | Android 15，API 35 |
| 设备 | sdk gphone64 x86 64，`emulator-5554` |
| 截图逻辑尺寸 | 375 × 812 |
| 截图像素尺寸 | 750 × 1624，2 倍密度 |

## 检查覆盖

### 静态与自动化检查

- `flutter analyze`：无问题。
- `flutter test`：58 项检查通过，其中 4 项状态测试、54 项页面布局测试。
- Android 模拟器端到端交互：注册校验与提交、卖家关注、搜索筛选、作品详情、收藏、无效竞价、有效竞价、余额更新、资料保存和本地作品发布。
- Android 实际页面采集：30 个参考状态，对应 `docs/screenshots/` 中的 30 张 PNG。

### 状态测试

| 检查 | 验证内容 |
| --- | --- |
| 非法竞价 | NaN、无穷值、负数、低于最低价、余额不足时不改变余额 |
| 重复出价 | 只保留提价差额，改名后仍能识别自己的出价；重建状态后恢复价格和余额 |
| 个人状态 | 资料、关注、收藏、钱包和登录状态保存；退出清除登录与钱包连接 |
| 本地作品 | 作品和图片可恢复，清空通知后重启仍为空列表 |

### 页面适配

18 个基础页面分别在 320 × 640、375 × 812、480 × 900 三种逻辑尺寸下验证，共 54 项。检查可见组件的布局异常，避免 RenderFlex 溢出。另通过模拟器采集表单填写、菜单、弹层、加载和空状态等原稿变体。

布局测试加载随应用打包的实际字体。曾遇到本机 Flutter Windows 测试引擎处理 DM Sans 可变字体时崩溃，最终改用固定 Regular / Bold 文件，完整测试通过。

## 本地复现

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d emulator-5554
```

Android 设备编号不同，可先执行 `flutter devices` 并替换设备编号。

## 重新生成全部截图

先将模拟器显示调整为设计尺寸。以下命令假设 Android SDK 位于当前用户的默认目录，调整的是模拟器显示参数。

```powershell
$adbPath = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
& $adbPath -s emulator-5554 shell wm size 750x1624
& $adbPath -s emulator-5554 shell wm density 320

flutter build apk --profile --target-platform android-x64 --target integration_test/app_test.dart
flutter drive --profile --use-application-binary=build/app/outputs/flutter-apk/app-profile.apk --driver=test_driver/integration_driver.dart --target=integration_test/app_test.dart -d emulator-5554
```

测试驱动会将原尺寸 PNG 写入 `docs/screenshots/`。命名与 Pixso 画板编号对应；每张是实际 Flutter 画面，没有用原稿替代运行结果。脚本使用隔离的演示存储，避免将自动化测试资料写入正常用户的存储。

使用 Profile 构建是因为当前模拟器空闲存储不足以安装约 150 MB 的 Debug 测试包；实际布局异常检测由开启断言的 Widget 测试完成。Profile 集成测试负责设备上的渲染、导航和业务流程检查。

如果只需要快速重跑交互，构建时加 `--dart-define=CAPTURE=false`，会跳过 30 张截图的采集。

如需恢复本次任务开始前的模拟器显示配置：

```powershell
& $adbPath -s emulator-5554 shell wm size 1080x2340
& $adbPath -s emulator-5554 shell wm density 440
```

这两个值是本次开始时读取到的覆盖配置。其他设备应恢复为自己的原值，或使用 `wm size reset`、`wm density reset` 恢复设备默认值。

## 构建可安装包

```powershell
flutter build apk --release --split-per-abi
```

- ARM64 真机：`build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`。
- x86_64 模拟器：`build/app/outputs/flutter-apk/app-x86_64-release.apk`。
- 交付副本放在 `dist/`，便于直接验收。

正式发布前需更换开发签名，并接入真实认证、钱包与服务端。iOS 工程包含相册用途说明，但本次在 Windows 上未执行 Xcode 构建；系统相册的文件选择结果依赖实际设备权限，自动化中的作品发布验证覆盖的是选图后数据和收藏展示流程。

# 灵感火花 Inspiration Spark

卡通风安卓记事 App：左侧灵感蓝区、右侧记事粉区，支持文字输入与语音转文字，可一键添加桌面快捷方式。

## 功能

- 左右分栏：灵感（蓝） / 记事（粉）；手机竖屏用顶部切换
- 语音输入（系统语音识别，默认中文）或键盘输入
- 本地保存（SharedPreferences）
- 一键请求固定桌面快捷方式；长按图标可用「写灵感 / 写记事」快捷操作

## 构建 APK

```bash
cd apps/inspiration_spark
flutter pub get
flutter build apk --release
```

产物：`build/app/outputs/flutter-apk/app-release.apk`

## 说明

GitHub 上常见笔记模板（Saber / Butterfly / notes-app 等）偏手写或 Markdown，与「卡通左右双区 + 语音」需求不符，因此基于 Flutter 新建轻量应用。

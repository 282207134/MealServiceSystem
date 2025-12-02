# 📦 部署指南

本文档提供校园点餐系统的完整部署流程，包括开发环境、测试环境和生产环境的部署步骤。

---

## 📋 目录

- [部署前准备](#部署前准备)
- [Supabase 后端部署](#supabase-后端部署)
- [Flutter 应用构建](#flutter-应用构建)
- [Android 应用部署](#android-应用部署)
- [iOS 应用部署](#ios-应用部署)
- [Web 应用部署](#web-应用部署)
- [持续集成/持续部署](#持续集成持续部署)
- [监控和维护](#监控和维护)
- [常见问题排查](#常见问题排查)

---

## 部署前准备

### 检查清单

在开始部署前，请确认以下项目已完成：

#### ✅ 代码质量检查

```bash
# 1. 代码格式化
flutter format lib/

# 2. 代码分析（无警告）
flutter analyze

# 3. 运行所有测试
flutter test

# 4. 检查依赖更新
flutter pub outdated
```

#### ✅ 配置文件检查

- [ ] `supabase_config.dart` 已配置生产环境的 URL 和 Key
- [ ] `app_config.dart` 中 `isDebugMode` 设置为 `false`
- [ ] 所有敏感信息已从代码中移除
- [ ] `.gitignore` 已配置正确

#### ✅ 功能测试

- [ ] 用户注册和登录功能正常
- [ ] 商品浏览和搜索功能正常
- [ ] 购物车和下单功能正常
- [ ] 订单管理功能正常（顾客端和商家端）
- [ ] 图片上传功能正常
- [ ] 实时订单通知功能正常

#### ✅ 性能测试

- [ ] 页面加载速度（< 3秒）
- [ ] 图片加载优化
- [ ] 内存使用正常
- [ ] 网络请求优化

---

## Supabase 后端部署

### 步骤 1：创建生产环境项目

1. 访问 [Supabase Dashboard](https://app.supabase.com/)

2. 点击 **"New project"**

3. 填写项目信息：
   ```
   项目名称：food-ordering-prod
   数据库密码：（生成强密码并保存）
   区域：选择离用户最近的区域（建议：Asia Pacific (Tokyo) 或 Southeast Asia (Singapore)）
   定价计划：根据需求选择（开发阶段可选 Free，生产环境建议 Pro）
   ```

4. 等待项目创建完成（约 2-3 分钟）

### 步骤 2：配置数据库

#### 2.1 执行数据库迁移

1. 在 Supabase Dashboard 中，进入 **SQL Editor**

2. 创建新查询，复制 `supabase_migration.sql` 的全部内容

3. 点击 **"Run"** 执行脚本

4. 验证表是否创建成功：
   ```sql
   -- 查看所有表
   SELECT table_name 
   FROM information_schema.tables 
   WHERE table_schema = 'public' 
     AND table_type = 'BASE TABLE'
   ORDER BY table_name;
   ```

5. 预期结果应包含：
   - users
   - merchants
   - categories
   - products
   - orders
   - order_items

#### 2.2 配置 Row Level Security (RLS)

RLS 策略已在迁移脚本中自动创建，验证是否启用：

```sql
-- 检查 RLS 是否启用
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public';
```

所有表的 `rowsecurity` 应该为 `true`。

#### 2.3 创建索引（如果未自动创建）

```sql
-- 验证索引
SELECT indexname, tablename
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
```

### 步骤 3：配置 Storage

#### 3.1 创建 Storage Bucket

1. 在 Supabase Dashboard 中，进入 **Storage**

2. 点击 **"Create a new bucket"**

3. 配置 Bucket：
   ```
   名称：product-images
   公开访问：Public（勾选 "Public bucket"）
   ```

4. 点击 **"Create bucket"**

#### 3.2 配置 Storage 策略

1. 选择 `product-images` bucket

2. 点击 **"Policies"** 标签

3. 添加以下策略：

**上传策略（允许认证用户上传）：**

```sql
CREATE POLICY "认证用户可以上传图片"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'product-images');
```

**读取策略（允许所有人读取）：**

```sql
CREATE POLICY "所有人可以读取图片"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'product-images');
```

**删除策略（仅所有者可删除）：**

```sql
CREATE POLICY "所有者可以删除图片"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'product-images' AND auth.uid()::text = owner);
```

### 步骤 4：配置认证

#### 4.1 启用邮箱认证

1. 进入 **Authentication** → **Providers**

2. 启用 **Email** provider

3. 配置邮件模板（可选）：
   - 进入 **Email Templates**
   - 自定义 "Confirm signup"、"Reset password" 等模板

#### 4.2 配置 Site URL

1. 进入 **Authentication** → **URL Configuration**

2. 设置 **Site URL**：
   ```
   开发环境：http://localhost:3000
   生产环境：https://yourdomain.com
   ```

3. 添加 **Redirect URLs**（如果使用第三方登录）

#### 4.3 配置安全设置

1. 进入 **Authentication** → **Settings**

2. 推荐配置：
   ```
   ✅ Enable email confirmations（启用邮箱验证）
   ✅ Enable password requirements（启用密码强度要求）
   最小密码长度：6
   ⬜ Disable signup（根据需求，可在后期启用）
   ```

### 步骤 5：获取 API 密钥

1. 进入 **Settings** → **API**

2. 记录以下信息（务必安全保存）：
   ```
   Project URL: https://xxxxx.supabase.co
   anon (public) key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...（仅服务端使用，不要暴露）
   ```

3. 更新应用配置文件 `lib/core/config/supabase_config.dart`：
   ```dart
   class SupabaseConfig {
     static const String url = 'https://xxxxx.supabase.co';
     static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
     // 其他配置...
   }
   ```

### 步骤 6：备份数据库

设置定期备份（Pro 计划功能）：

1. 进入 **Settings** → **Database**

2. 启用 **Point-in-Time Recovery (PITR)**（建议）

3. 手动备份（可选）：
   ```bash
   # 使用 pg_dump
   pg_dump -h db.xxxxx.supabase.co -U postgres -d postgres > backup.sql
   ```

---

## Flutter 应用构建

### 步骤 1：更新版本号

编辑 `pubspec.yaml`：

```yaml
version: 1.0.0+1
# 格式：主版本.次版本.修订版本+构建号
# 每次发布都要更新
```

### 步骤 2：配置应用信息

#### Android 配置

编辑 `android/app/build.gradle`：

```gradle
android {
    defaultConfig {
        applicationId "com.yourcompany.food_ordering_app"  // 修改为你的包名
        minSdkVersion 21  // 最低支持 Android 5.0
        targetSdkVersion 33  // 目标 SDK 版本
        versionCode 1  // 与 pubspec.yaml 中的构建号保持一致
        versionName "1.0.0"  // 与 pubspec.yaml 中的版本号保持一致
    }
}
```

编辑 `android/app/src/main/AndroidManifest.xml`：

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.yourcompany.food_ordering_app">
    
    <application
        android:label="校园点餐"
        android:icon="@mipmap/ic_launcher">
        <!-- 其他配置 -->
    </application>
    
    <!-- 权限配置 -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
</manifest>
```

#### iOS 配置

编辑 `ios/Runner/Info.plist`：

```xml
<dict>
    <key>CFBundleName</key>
    <string>校园点餐</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    
    <!-- 权限说明 -->
    <key>NSCameraUsageDescription</key>
    <string>需要访问相机以上传商品图片</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>需要访问相册以选择商品图片</string>
</dict>
```

### 步骤 3：准备应用图标

#### 使用 flutter_launcher_icons

1. 安装依赖（已在 `pubspec.yaml` 中添加）：
   ```yaml
   dev_dependencies:
     flutter_launcher_icons: ^0.13.0
   ```

2. 配置图标（添加到 `pubspec.yaml`）：
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/icons/app_icon.png"  # 准备 1024x1024 的图标
     adaptive_icon_background: "#FFFFFF"
     adaptive_icon_foreground: "assets/icons/app_icon_foreground.png"
   ```

3. 生成图标：
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

---

## Android 应用部署

### 步骤 1：生成签名密钥

#### 1.1 创建密钥库

```bash
# 在项目根目录执行
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# 按提示输入信息：
# - 密钥库密码（务必记住）
# - 姓名、组织等信息
```

#### 1.2 配置密钥属性

创建 `android/key.properties`（不要提交到 Git）：

```properties
storePassword=你的密钥库密码
keyPassword=你的密钥密码
keyAlias=upload
storeFile=upload-keystore.jks
```

#### 1.3 配置 Gradle

编辑 `android/app/build.gradle`，在 `android` 块之前添加：

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... 其他配置

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 步骤 2：构建 Release 版本

#### 2.1 构建 APK

```bash
# 清理之前的构建
flutter clean

# 获取依赖
flutter pub get

# 构建 APK
flutter build apk --release

# 构建结果位置：
# build/app/outputs/flutter-apk/app-release.apk
```

#### 2.2 构建 App Bundle（推荐用于 Google Play）

```bash
# 构建 App Bundle
flutter build appbundle --release

# 构建结果位置：
# build/app/outputs/bundle/release/app-release.aab
```

### 步骤 3：测试 Release 版本

```bash
# 安装到连接的设备
flutter install --release

# 或手动安装 APK
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 步骤 4：发布到 Google Play（可选）

#### 4.1 创建 Google Play 开发者账号

1. 访问 [Google Play Console](https://play.google.com/console/)
2. 支付一次性注册费用（$25 USD）
3. 完善开发者资料

#### 4.2 创建应用

1. 点击 **"创建应用"**
2. 填写应用信息：
   - 应用名称：校园点餐
   - 默认语言：中文（简体）
   - 应用类型：应用
   - 免费/付费：免费

#### 4.3 完成应用设置

按照 Google Play Console 的向导完成：

1. **应用内容**
   - 隐私政策
   - 应用访问权限
   - 广告（如果有）
   - 内容分级

2. **准备发布**
   - 国家/地区
   - 版本发布

3. **上传 App Bundle**
   - 进入 **"发布"** → **"生产"**
   - 点击 **"创建新版本"**
   - 上传 `app-release.aab`
   - 填写版本说明

4. **提交审核**
   - 检查所有必填项
   - 提交审核（通常需要 1-7 天）

---

## iOS 应用部署

### 步骤 1：准备开发者账号

1. 注册 [Apple Developer Program](https://developer.apple.com/programs/)
   - 费用：$99 USD/年
   - 完成注册和验证

### 步骤 2：配置 Xcode

#### 2.1 打开 iOS 项目

```bash
# 确保安装了 CocoaPods
sudo gem install cocoapods

# 安装 iOS 依赖
cd ios
pod install
cd ..

# 打开 Xcode 项目
open ios/Runner.xcworkspace
```

#### 2.2 配置签名

1. 在 Xcode 中，选择 **Runner** 项目
2. 选择 **Signing & Capabilities** 标签
3. 配置：
   ```
   Team: 选择你的开发团队
   Bundle Identifier: com.yourcompany.foodOrderingApp（必须唯一）
   ✅ Automatically manage signing
   ```

### 步骤 3：配置 App Store Connect

#### 3.1 创建应用

1. 访问 [App Store Connect](https://appstoreconnect.apple.com/)
2. 点击 **"我的 App"** → **"+"** → **"新建 App"**
3. 填写信息：
   ```
   平台：iOS
   名称：校园点餐
   主要语言：简体中文
   套装 ID：选择刚才配置的 Bundle Identifier
   SKU：food-ordering-app-001（自定义）
   用户访问权限：完全访问权限
   ```

#### 3.2 配置应用信息

1. **App 信息**
   - 名称、副标题
   - 类别：美食佳饮
   - 内容版权：© 2024 Your Company

2. **定价与销售范围**
   - 价格：免费
   - 销售范围：选择要发布的国家/地区

3. **App 隐私**
   - 配置隐私详情
   - 数据收集说明

### 步骤 4：构建和上传

#### 4.1 构建 iOS 应用

```bash
# 确保在项目根目录
flutter clean
flutter pub get

# 构建 iOS 应用
flutter build ios --release
```

#### 4.2 使用 Xcode Archive

1. 在 Xcode 中，选择目标设备为 **"Any iOS Device (arm64)"**

2. 选择菜单 **Product** → **Archive**

3. 等待 Archive 完成（可能需要几分钟）

4. 在 Organizer 窗口中：
   - 选择刚才创建的 Archive
   - 点击 **"Distribute App"**
   - 选择 **"App Store Connect"**
   - 选择 **"Upload"**
   - 完成上传向导

#### 4.3 提交审核

1. 返回 App Store Connect

2. 进入应用页面 → **TestFlight** 或 **App Store**

3. 创建新版本：
   - 选择刚上传的构建版本
   - 填写 **"此版本的新增内容"**
   - 上传截图（至少 3 张）
   - 填写描述、关键词等

4. 提交审核
   - 审核通常需要 1-3 天

---

## Web 应用部署

### 步骤 1：构建 Web 应用

```bash
# 启用 Web 支持（如果尚未启用）
flutter config --enable-web

# 构建 Web 应用
flutter build web --release

# 构建结果位置：build/web/
```

### 步骤 2：部署到 Firebase Hosting（推荐）

#### 2.1 安装 Firebase CLI

```bash
npm install -g firebase-tools

# 登录 Firebase
firebase login
```

#### 2.2 初始化 Firebase

```bash
# 在项目根目录
firebase init hosting

# 选择配置：
# Public directory: build/web
# Configure as single-page app: Yes
# Set up automatic builds with GitHub: No (可选)
```

#### 2.3 部署

```bash
# 部署到 Firebase
firebase deploy --only hosting

# 部署完成后会显示 URL
# Hosting URL: https://your-project.web.app
```

### 步骤 3：部署到 Vercel（替代方案）

```bash
# 安装 Vercel CLI
npm install -g vercel

# 部署
cd build/web
vercel

# 按提示完成配置
```

### 步骤 4：配置自定义域名（可选）

#### Firebase Hosting

1. 在 Firebase Console → **Hosting**
2. 点击 **"添加自定义域"**
3. 按向导配置 DNS 记录

#### 配置 HTTPS

Firebase Hosting 自动提供免费 SSL 证书。

---

## 持续集成/持续部署

### GitHub Actions 配置

创建 `.github/workflows/deploy.yml`：

```yaml
name: 部署应用

on:
  push:
    branches: [ main ]
    tags:
      - 'v*'
  pull_request:
    branches: [ main ]

jobs:
  # 代码质量检查
  analyze:
    name: 代码分析
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
      
      - name: 获取依赖
        run: flutter pub get
      
      - name: 代码分析
        run: flutter analyze
      
      - name: 运行测试
        run: flutter test

  # 构建 Android
  build-android:
    name: 构建 Android
    needs: analyze
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '11'
      
      - name: 获取依赖
        run: flutter pub get
      
      - name: 构建 APK
        run: flutter build apk --release
      
      - name: 上传 APK
        uses: actions/upload-artifact@v3
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  # 构建 iOS（需要 macOS runner）
  build-ios:
    name: 构建 iOS
    needs: analyze
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: 安装依赖
        run: |
          cd ios
          pod install
          cd ..
      
      - name: 构建 iOS
        run: flutter build ios --release --no-codesign
      
      - name: 压缩构建产物
        run: |
          cd build/ios/iphoneos
          tar -czf Runner.app.tar.gz Runner.app
      
      - name: 上传 iOS 构建
        uses: actions/upload-artifact@v3
        with:
          name: ios-build
          path: build/ios/iphoneos/Runner.app.tar.gz
```

### GitLab CI 配置

创建 `.gitlab-ci.yml`：

```yaml
stages:
  - test
  - build
  - deploy

variables:
  FLUTTER_VERSION: "3.16.0"

# 测试阶段
test:
  stage: test
  image: ghcr.io/cirruslabs/flutter:${FLUTTER_VERSION}
  script:
    - flutter pub get
    - flutter analyze
    - flutter test
  only:
    - merge_requests
    - main

# 构建 Android
build-android:
  stage: build
  image: ghcr.io/cirruslabs/flutter:${FLUTTER_VERSION}
  script:
    - flutter pub get
    - flutter build apk --release
  artifacts:
    paths:
      - build/app/outputs/flutter-apk/app-release.apk
    expire_in: 1 week
  only:
    - main
    - tags

# 部署到 Firebase
deploy-web:
  stage: deploy
  image: node:16
  before_script:
    - npm install -g firebase-tools
  script:
    - flutter build web --release
    - firebase deploy --only hosting --token $FIREBASE_TOKEN
  only:
    - main
```

---

## 监控和维护

### 错误追踪

#### 集成 Sentry

1. 添加依赖：
   ```yaml
   dependencies:
     sentry_flutter: ^7.0.0
   ```

2. 初始化 Sentry：
   ```dart
   import 'package:sentry_flutter/sentry_flutter.dart';

   Future<void> main() async {
     await SentryFlutter.init(
       (options) {
         options.dsn = 'YOUR_SENTRY_DSN';
         options.environment = 'production';
       },
       appRunner: () => runApp(MyApp()),
     );
   }
   ```

### 性能监控

#### Supabase Analytics

在 Supabase Dashboard 中查看：
- API 请求统计
- 数据库性能
- 存储使用情况

### 日志管理

```dart
// 使用统一的日志系统
import 'package:logger/logger.dart';

class AppLogger {
  static final logger = Logger(
    printer: PrettyPrinter(),
    level: Level.info, // 生产环境使用 Level.warning
  );
}

// 使用
AppLogger.logger.i('订单创建成功');
AppLogger.logger.e('网络请求失败', error: error);
```

---

## 常见问题排查

### Android 构建问题

#### 问题 1：Gradle 构建失败

```bash
# 清理构建缓存
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### 问题 2：签名错误

检查 `android/key.properties` 文件路径是否正确。

### iOS 构建问题

#### 问题 1：CocoaPods 错误

```bash
cd ios
pod deintegrate
pod install
cd ..
```

#### 问题 2：证书问题

在 Xcode 中重新选择开发团队和证书。

### Supabase 连接问题

#### 问题 1：CORS 错误（Web）

在 Supabase Dashboard → **Settings** → **API** 中添加允许的域名。

#### 问题 2：认证失败

检查 Supabase 配置的 Site URL 是否正确。

---

## 版本更新流程

### 发布新版本

1. **更新版本号**
   ```yaml
   # pubspec.yaml
   version: 1.0.1+2  # 从 1.0.0+1 递增
   ```

2. **更新变更日志**
   创建 `CHANGELOG.md` 记录更新内容

3. **测试**
   ```bash
   flutter test
   flutter build apk --release  # 测试构建
   ```

4. **构建和发布**
   - Android：构建新 APK/AAB 并上传到 Google Play
   - iOS：Archive 并上传到 App Store Connect
   - Web：执行 `firebase deploy`

5. **监控**
   - 检查错误报告
   - 收集用户反馈
   - 监控性能指标

---

## 回滚流程

### Android

在 Google Play Console 中：
1. 进入 **发布** → **生产**
2. 选择之前的版本
3. 点击 **"将此版本回滚到生产轨道"**

### iOS

在 App Store Connect 中：
1. 进入应用页面
2. 选择 **"App Store"** 标签
3. 移除当前版本
4. 重新提交之前的版本

### Web

```bash
# Firebase Hosting
firebase hosting:rollback
```

---

## 安全检查清单

发布前的安全检查：

- [ ] 所有 API 密钥已从代码中移除
- [ ] Supabase RLS 策略已正确配置
- [ ] HTTPS 已启用
- [ ] 用户输入已验证
- [ ] SQL 注入防护已实施
- [ ] XSS 攻击防护已实施
- [ ] 敏感数据已加密
- [ ] 日志中不包含敏感信息

---

## 备份策略

### 数据库备份

```bash
# 每日自动备份（使用 cron）
0 2 * * * pg_dump -h db.xxxxx.supabase.co -U postgres -d postgres > /backup/db_$(date +\%Y\%m\%d).sql
```

### 代码备份

使用 Git 版本控制：
```bash
# 创建发布标签
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

---

**部署文档版本：** 1.0.0  
**最后更新：** 2024-11  
**维护者：** 开发团队

**下一步阅读：**
- [监控和日志文档](MONITORING.md)
- [安全最佳实践](SECURITY.md)
- [性能优化指南](PERFORMANCE.md)

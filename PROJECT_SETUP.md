# 项目配置指南

本文档提供详细的项目配置步骤和配置文件示例。

## 📋 目录

- [创建 Flutter 项目](#创建-flutter-项目)
- [配置文件示例](#配置文件示例)
- [目录结构创建](#目录结构创建)
- [必要的配置文件](#必要的配置文件)
- [开发工具配置](#开发工具配置)

---

## 创建 Flutter 项目

### 步骤 1: 创建项目

```bash
# 创建新项目
flutter create food_ordering_app

# 进入项目目录
cd food_ordering_app

# 验证项目创建成功
flutter doctor -v
```

### 步骤 2: 添加依赖

编辑 `pubspec.yaml` 文件：

```yaml
name: food_ordering_app
description: 校园点餐系统 - 基于 Flutter 和 Supabase
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # Supabase
  supabase_flutter: ^2.0.0
  
  # 状态管理
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  
  # 路由导航
  go_router: ^12.0.0
  
  # UI 相关
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  flutter_staggered_grid_view: ^0.7.0
  
  # 图片选择和处理
  image_picker: ^1.0.0
  image_cropper: ^5.0.0
  
  # 工具类
  intl: ^0.18.0
  uuid: ^4.0.0
  equatable: ^2.0.5
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  
  # 本地存储
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # 网络状态检测
  connectivity_plus: ^5.0.0
  
  # 日志
  logger: ^2.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # 代码生成
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  freezed: ^2.4.5
  json_serializable: ^6.7.1
  
  # 代码规范
  flutter_lints: ^3.0.0
  
  # 测试
  mockito: ^5.4.0
  bloc_test: ^9.1.0

flutter:
  uses-material-design: true
  
  # 资源文件
  assets:
    - assets/images/
    - assets/icons/
    - assets/fonts/
  
  # 字体配置
  fonts:
    - family: NotoSansSC
      fonts:
        - asset: assets/fonts/NotoSansSC-Regular.ttf
        - asset: assets/fonts/NotoSansSC-Bold.ttf
          weight: 700
```

### 步骤 3: 安装依赖

```bash
# 获取依赖包
flutter pub get

# 运行代码生成（如果使用了代码生成）
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 配置文件示例

### 1. Supabase 配置文件

创建 `lib/core/config/supabase_config.dart`：

```dart
/// Supabase 配置类
/// 
/// 存储 Supabase 项目的连接信息
/// 
/// ⚠️ 警告：此文件包含敏感信息，请勿提交到版本控制系统
class SupabaseConfig {
  /// Supabase 项目 URL
  /// 
  /// 格式：https://xxx.supabase.co
  /// 在 Supabase 项目设置 -> API 中获取
  static const String url = 'YOUR_SUPABASE_PROJECT_URL';
  
  /// Supabase Anon (Public) Key
  /// 
  /// 这是公开密钥，可以在客户端安全使用
  /// 在 Supabase 项目设置 -> API 中获取
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  /// Storage Bucket 名称
  static const String productImagesBucket = 'product-images';
  
  /// 是否启用实时订阅
  static const bool enableRealtimeSubscription = true;
}
```

创建 `lib/core/config/supabase_config.example.dart`（可以提交到 Git）：

```dart
/// Supabase 配置示例文件
/// 
/// 复制此文件为 supabase_config.dart 并填入实际的配置信息
class SupabaseConfig {
  static const String url = 'https://your-project.supabase.co';
  static const String anonKey = 'your-anon-key-here';
  static const String productImagesBucket = 'product-images';
  static const bool enableRealtimeSubscription = true;
}
```

### 2. 应用配置文件

创建 `lib/core/config/app_config.dart`：

```dart
/// 应用配置类
/// 
/// 存储应用级别的配置信息
class AppConfig {
  /// 应用名称
  static const String appName = '校园点餐';
  
  /// 应用版本
  static const String appVersion = '1.0.0';
  
  /// 构建号
  static const int buildNumber = 1;
  
  /// 是否为调试模式
  static const bool isDebugMode = true;
  
  /// API 超时时间（秒）
  static const int apiTimeout = 30;
  
  /// 图片缓存大小（MB）
  static const int imageCacheSize = 100;
  
  /// 每页加载数量
  static const int pageSize = 20;
  
  /// 支持的语言
  static const List<String> supportedLocales = ['zh_CN', 'en_US'];
  
  /// 默认语言
  static const String defaultLocale = 'zh_CN';
}
```

### 3. 颜色常量

创建 `lib/core/constants/app_colors.dart`：

```dart
import 'package:flutter/material.dart';

/// 应用颜色常量
/// 
/// 定义应用中使用的所有颜色
class AppColors {
  // 主题色
  /// 主色调 - 红色
  static const Color primary = Color(0xFFFF6B6B);
  
  /// 主色调 - 深色
  static const Color primaryDark = Color(0xFFE74C3C);
  
  /// 主色调 - 浅色
  static const Color primaryLight = Color(0xFFFF9999);
  
  /// 辅助色 - 青色
  static const Color secondary = Color(0xFF4ECDC4);
  
  /// 强调色 - 黄色
  static const Color accent = Color(0xFFFFE66D);
  
  // 文字颜色
  /// 主要文字颜色
  static const Color textPrimary = Color(0xFF2D3436);
  
  /// 次要文字颜色
  static const Color textSecondary = Color(0xFF636E72);
  
  /// 浅色文字颜色
  static const Color textLight = Color(0xFFB2BEC3);
  
  /// 禁用文字颜色
  static const Color textDisabled = Color(0xFFDFE6E9);
  
  // 背景颜色
  /// 页面背景色
  static const Color background = Color(0xFFF5F5F5);
  
  /// 卡片背景色
  static const Color surface = Color(0xFFFFFFFF);
  
  /// 分割线颜色
  static const Color divider = Color(0xFFECF0F1);
  
  // 状态颜色
  /// 成功状态
  static const Color success = Color(0xFF27AE60);
  
  /// 警告状态
  static const Color warning = Color(0xFFF39C12);
  
  /// 错误状态
  static const Color error = Color(0xFFE74C3C);
  
  /// 信息状态
  static const Color info = Color(0xFF3498DB);
  
  // 订单状态颜色
  /// 待确认
  static const Color orderPending = Color(0xFFF39C12);
  
  /// 已确认
  static const Color orderConfirmed = Color(0xFF3498DB);
  
  /// 制作中
  static const Color orderPreparing = Color(0xFF9B59B6);
  
  /// 待取餐
  static const Color orderReady = Color(0xFF27AE60);
  
  /// 已完成
  static const Color orderCompleted = Color(0xFF95A5A6);
  
  /// 已取消
  static const Color orderCancelled = Color(0xFFE74C3C);
}
```

### 4. 字符串常量

创建 `lib/core/constants/app_strings.dart`：

```dart
/// 应用字符串常量
/// 
/// 定义应用中使用的所有文本字符串
/// 便于国际化和统一管理
class AppStrings {
  // 应用名称
  static const String appName = '校园点餐';
  
  // 通用
  static const String confirm = '确认';
  static const String cancel = '取消';
  static const String save = '保存';
  static const String delete = '删除';
  static const String edit = '编辑';
  static const String add = '添加';
  static const String search = '搜索';
  static const String loading = '加载中...';
  static const String retry = '重试';
  static const String refresh = '刷新';
  static const String submit = '提交';
  static const String back = '返回';
  static const String next = '下一步';
  static const String done = '完成';
  static const String close = '关闭';
  
  // 认证相关
  static const String login = '登录';
  static const String register = '注册';
  static const String logout = '退出登录';
  static const String email = '邮箱';
  static const String password = '密码';
  static const String confirmPassword = '确认密码';
  static const String forgotPassword = '忘记密码？';
  static const String resetPassword = '重置密码';
  static const String fullName = '姓名';
  static const String phone = '手机号';
  
  // 商品相关
  static const String products = '商品';
  static const String productName = '商品名称';
  static const String productDescription = '商品描述';
  static const String productPrice = '商品价格';
  static const String productImage = '商品图片';
  static const String category = '分类';
  static const String stock = '库存';
  static const String available = '可用';
  static const String unavailable = '不可用';
  
  // 订单相关
  static const String orders = '订单';
  static const String orderNumber = '订单号';
  static const String orderStatus = '订单状态';
  static const String orderTotal = '订单总额';
  static const String orderNote = '订单备注';
  static const String orderHistory = '历史订单';
  
  // 订单状态
  static const String orderPending = '待确认';
  static const String orderConfirmed = '已确认';
  static const String orderPreparing = '制作中';
  static const String orderReady = '待取餐';
  static const String orderCompleted = '已完成';
  static const String orderCancelled = '已取消';
  
  // 购物车相关
  static const String cart = '购物车';
  static const String addToCart = '加入购物车';
  static const String cartEmpty = '购物车为空';
  static const String checkout = '结算';
  static const String totalAmount = '总计';
  
  // 商家相关
  static const String merchant = '商家';
  static const String merchantName = '商家名称';
  static const String merchantDescription = '商家简介';
  static const String menuManagement = '菜单管理';
  static const String orderManagement = '订单管理';
  
  // 用户相关
  static const String profile = '我的';
  static const String settings = '设置';
  static const String aboutUs = '关于我们';
  
  // 错误消息
  static const String errorNetwork = '网络连接失败';
  static const String errorUnknown = '未知错误';
  static const String errorLoadData = '加载数据失败';
  static const String errorSaveData = '保存数据失败';
  static const String errorInvalidInput = '输入无效';
  static const String errorEmptyField = '此字段不能为空';
  static const String errorInvalidEmail = '邮箱格式不正确';
  static const String errorPasswordTooShort = '密码长度不能少于6位';
  static const String errorPasswordNotMatch = '两次输入的密码不一致';
  
  // 成功消息
  static const String successSaved = '保存成功';
  static const String successDeleted = '删除成功';
  static const String successUpdated = '更新成功';
  static const String successCreated = '创建成功';
}
```

### 5. 主题配置

创建 `lib/core/theme/app_theme.dart`：

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 应用主题配置
class AppTheme {
  /// 亮色主题
  static ThemeData get lightTheme {
    return ThemeData(
      // 使用 Material 3
      useMaterial3: true,
      
      // 颜色方案
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        background: AppColors.background,
        surface: AppColors.surface,
      ),
      
      // 应用栏主题
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      
      // 卡片主题
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // 文字按钮主题
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      
      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 8,
      ),
      
      // 浮动操作按钮主题
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      
      // 文字主题
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
  
  /// 深色主题（可选）
  static ThemeData get darkTheme {
    // TODO: 实现深色主题
    return lightTheme;
  }
}
```

---

## 目录结构创建

使用以下脚本快速创建项目目录结构：

### Bash 脚本（Linux/MacOS）

创建 `setup_structure.sh`：

```bash
#!/bin/bash

# 项目根目录
ROOT="lib"

# 创建核心目录
mkdir -p $ROOT/core/{config,constants,theme,utils,error}

# 创建数据层目录
mkdir -p $ROOT/data/{models,repositories,datasources/{remote,local}}

# 创建领域层目录
mkdir -p $ROOT/domain/{entities,repositories,usecases/{auth,product,order,merchant}}

# 创建展示层目录
mkdir -p $ROOT/presentation/{providers,widgets/{common,product,order},router}

# 创建顾客端页面目录
mkdir -p $ROOT/presentation/screens/customer/{home,menu,cart,orders,profile}
mkdir -p $ROOT/presentation/screens/customer/home/widgets
mkdir -p $ROOT/presentation/screens/customer/menu/widgets
mkdir -p $ROOT/presentation/screens/customer/cart/widgets
mkdir -p $ROOT/presentation/screens/customer/orders/widgets
mkdir -p $ROOT/presentation/screens/customer/profile/widgets

# 创建商家端页面目录
mkdir -p $ROOT/presentation/screens/merchant/{dashboard,menu_management,order_management,settings}
mkdir -p $ROOT/presentation/screens/merchant/dashboard/widgets
mkdir -p $ROOT/presentation/screens/merchant/menu_management/widgets
mkdir -p $ROOT/presentation/screens/merchant/order_management/widgets
mkdir -p $ROOT/presentation/screens/merchant/settings/widgets

# 创建认证页面目录
mkdir -p $ROOT/presentation/screens/auth/{login,register}/widgets

# 创建启动页目录
mkdir -p $ROOT/presentation/screens/splash

# 创建资源目录
mkdir -p assets/{images,icons,fonts}

# 创建测试目录
mkdir -p test/{unit,widget,integration}

echo "✅ 目录结构创建完成！"
```

运行脚本：

```bash
chmod +x setup_structure.sh
./setup_structure.sh
```

### Windows PowerShell 脚本

创建 `setup_structure.ps1`：

```powershell
# 项目根目录
$ROOT = "lib"

# 创建核心目录
New-Item -ItemType Directory -Force -Path "$ROOT/core/config"
New-Item -ItemType Directory -Force -Path "$ROOT/core/constants"
New-Item -ItemType Directory -Force -Path "$ROOT/core/theme"
New-Item -ItemType Directory -Force -Path "$ROOT/core/utils"
New-Item -ItemType Directory -Force -Path "$ROOT/core/error"

# 创建数据层目录
New-Item -ItemType Directory -Force -Path "$ROOT/data/models"
New-Item -ItemType Directory -Force -Path "$ROOT/data/repositories"
New-Item -ItemType Directory -Force -Path "$ROOT/data/datasources/remote"
New-Item -ItemType Directory -Force -Path "$ROOT/data/datasources/local"

# 创建领域层目录
New-Item -ItemType Directory -Force -Path "$ROOT/domain/entities"
New-Item -ItemType Directory -Force -Path "$ROOT/domain/repositories"
New-Item -ItemType Directory -Force -Path "$ROOT/domain/usecases/auth"
New-Item -ItemType Directory -Force -Path "$ROOT/domain/usecases/product"
New-Item -ItemType Directory -Force -Path "$ROOT/domain/usecases/order"

# 创建展示层目录
New-Item -ItemType Directory -Force -Path "$ROOT/presentation/providers"
New-Item -ItemType Directory -Force -Path "$ROOT/presentation/widgets/common"
New-Item -ItemType Directory -Force -Path "$ROOT/presentation/widgets/product"
New-Item -ItemType Directory -Force -Path "$ROOT/presentation/widgets/order"
New-Item -ItemType Directory -Force -Path "$ROOT/presentation/router"

# 创建顾客端页面目录
New-Item -ItemType Directory -Force -Path "$ROOT/presentation/screens/customer/home/widgets"
New-Item -ItemType Directory -Force -Path "$ROOT/presentation/screens/customer/menu/widgets"
New-Item -ItemType Directory -Force -Path "$ROOT/presentation/screens/customer/cart/widgets"
New-Item -ItemType Directory -Force -Path "$ROOT/presentation/screens/customer/orders/widgets"

# 创建商家端页面目录
New-Item -ItemType Directory -Force -Path "$ROOT/presentation/screens/merchant/dashboard/widgets"
New-Item -ItemType Directory -Force -Path "$ROOT/presentation/screens/merchant/menu_management/widgets"
New-Item -ItemType Directory -Force -Path "$ROOT/presentation/screens/merchant/order_management/widgets"

# 创建资源目录
New-Item -ItemType Directory -Force -Path "assets/images"
New-Item -ItemType Directory -Force -Path "assets/icons"
New-Item -ItemType Directory -Force -Path "assets/fonts"

# 创建测试目录
New-Item -ItemType Directory -Force -Path "test/unit"
New-Item -ItemType Directory -Force -Path "test/widget"
New-Item -ItemType Directory -Force -Path "test/integration"

Write-Host "✅ 目录结构创建完成！" -ForegroundColor Green
```

运行脚本：

```powershell
.\setup_structure.ps1
```

---

## 必要的配置文件

### 1. 代码分析配置

创建 `analysis_options.yaml`：

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  
  errors:
    # 警告级别
    invalid_annotation_target: ignore
    deprecated_member_use: warning
    
  language:
    strict-casts: true
    strict-raw-types: true

linter:
  rules:
    # 错误
    avoid_print: true
    avoid_relative_lib_imports: true
    prefer_relative_imports: true
    
    # 样式
    always_declare_return_types: true
    prefer_single_quotes: true
    require_trailing_commas: true
    
    # 文档
    public_member_api_docs: false
    
    # 设计
    use_key_in_widget_constructors: true
```

### 2. 环境变量配置

创建 `.env.example`：

```env
# Supabase 配置
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# 应用配置
APP_NAME=校园点餐
DEBUG_MODE=true
```

---

## 开发工具配置

### VS Code 配置

创建 `.vscode/settings.json`：

```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "dart.debugExternalPackageLibraries": false,
  "dart.debugSdkLibraries": false,
  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code",
    "editor.formatOnSave": true,
    "editor.rulers": [80],
    "editor.selectionHighlight": false,
    "editor.suggest.snippetsPreventQuickSuggestions": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": false
  }
}
```

创建 `.vscode/launch.json`：

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (开发模式)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=DEBUG_MODE=true"
      ]
    },
    {
      "name": "Flutter (生产模式)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": [
        "--release",
        "--dart-define=DEBUG_MODE=false"
      ]
    }
  ]
}
```

### Android Studio / IntelliJ IDEA 配置

创建 `.idea/runConfigurations/dev.xml`：

```xml
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Dev Mode" type="FlutterRunConfigurationType" factoryName="Flutter">
    <option name="additionalArgs" value="--dart-define=DEBUG_MODE=true" />
    <option name="filePath" value="$PROJECT_DIR$/lib/main.dart" />
    <method v="2" />
  </configuration>
</component>
```

---

## 验证配置

创建完成后，运行以下命令验证配置：

```bash
# 检查 Flutter 环境
flutter doctor

# 获取依赖
flutter pub get

# 分析代码
flutter analyze

# 运行测试
flutter test

# 运行应用
flutter run
```

---

**文档版本：** 1.0.0  
**最后更新：** 2024-11

# 快速开始指南

## 🚀 5分钟快速启动

### 步骤 1: 克隆或创建项目

```bash
# 创建新的 Flutter 项目
flutter create food_ordering_app
cd food_ordering_app
```

### 步骤 2: 配置 Supabase

1. 访问 [https://supabase.com](https://supabase.com)
2. 创建新项目
3. 在项目设置中找到：
   - API URL
   - anon (public) key

4. 在 Supabase SQL Editor 中执行 `supabase_migration.sql` 文件的内容

5. 创建 Storage Bucket：
   - 名称：`product-images`
   - 访问权限：Public

### 步骤 3: 配置应用

创建配置文件：

```bash
mkdir -p lib/core/config
```

创建 `lib/core/config/supabase_config.dart`：

```dart
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_PROJECT_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

**重要：** 不要提交此文件到 Git！

### 步骤 4: 添加依赖

编辑 `pubspec.yaml`：

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.0.0
  flutter_riverpod: ^2.4.0
  go_router: ^12.0.0
  cached_network_image: ^3.3.0
  image_picker: ^1.0.0
  intl: ^0.18.0
  uuid: ^4.0.0
```

安装依赖：

```bash
flutter pub get
```

### 步骤 5: 初始化 Supabase

编辑 `lib/main.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '校园点餐系统',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('校园点餐系统')),
        body: Center(
          child: Text('欢迎使用校园点餐系统'),
        ),
      ),
    );
  }
}
```

### 步骤 6: 运行应用

```bash
# 检查设备
flutter devices

# 运行应用
flutter run
```

## 📁 推荐项目结构

创建以下目录结构：

```
lib/
├── core/
│   ├── config/
│   │   └── supabase_config.dart        # Supabase 配置（不提交）
│   ├── constants/
│   │   ├── app_colors.dart            # 颜色常量
│   │   ├── app_strings.dart           # 字符串常量
│   │   └── app_dimensions.dart        # 尺寸常量
│   ├── theme/
│   │   └── app_theme.dart             # 主题配置
│   └── utils/
│       ├── validators.dart            # 验证工具
│       └── formatters.dart            # 格式化工具
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── merchant_model.dart
│   │   ├── product_model.dart
│   │   ├── category_model.dart
│   │   ├── order_model.dart
│   │   └── order_item_model.dart
│   └── repositories/
│       ├── auth_repository.dart
│       ├── merchant_repository.dart
│       ├── product_repository.dart
│       └── order_repository.dart
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── merchant_provider.dart
│   │   ├── product_provider.dart
│   │   ├── cart_provider.dart
│   │   └── order_provider.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── customer/
│   │   │   ├── home_screen.dart
│   │   │   ├── menu_screen.dart
│   │   │   ├── cart_screen.dart
│   │   │   └── orders_screen.dart
│   │   └── merchant/
│   │       ├── dashboard_screen.dart
│   │       ├── menu_management_screen.dart
│   │       └── order_management_screen.dart
│   ├── widgets/
│   │   ├── product_card.dart
│   │   ├── order_card.dart
│   │   └── custom_button.dart
│   └── router/
│       └── app_router.dart
└── main.dart
```

## 🎯 下一步

### 对于顾客端开发：

1. 实现用户认证界面
2. 创建商家列表页面
3. 开发商品浏览功能
4. 实现购物车功能
5. 完成订单创建流程

### 对于商家端开发：

1. 创建商家注册流程
2. 开发商品管理界面
3. 实现订单接收和处理
4. 添加统计仪表盘

## 🔑 Supabase Auth 快速设置

### 邮箱密码认证

在 `lib/data/repositories/auth_repository.dart` 中：

```dart
class AuthRepository {
  final SupabaseClient _supabase;
  
  AuthRepository(this._supabase);
  
  // 注册
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role,
      },
    );
    
    return response;
  }
  
  // 登录
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    return response;
  }
  
  // 登出
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
  
  // 获取当前用户
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }
  
  // 监听认证状态变化
  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }
}
```

### 在 Supabase Dashboard 中配置认证

1. 进入 Authentication → Settings
2. 启用 Email provider
3. 配置 Email Templates（可选）
4. 设置 Site URL（应用的 URL）

## 📱 测试账号

使用 Supabase SQL Editor 创建测试账号：

```sql
-- 首先在 Supabase Auth 中创建用户（通过 Dashboard 或 API）
-- 然后在 users 表中插入对应记录

-- 商家测试账号
-- Email: merchant@test.com
-- Password: test123456

-- 顾客测试账号
-- Email: customer@test.com
-- Password: test123456
```

## ⚠️ 常见问题

### Q: 无法连接到 Supabase？
- 检查 API URL 和 anon key 是否正确
- 确认网络连接正常
- 查看 Supabase 项目状态

### Q: RLS 策略导致无法访问数据？
- 检查用户是否已登录
- 确认 RLS 策略配置正确
- 在开发阶段可以临时禁用 RLS 测试

### Q: 图片上传失败？
- 确认 Storage Bucket 已创建
- 检查 Bucket 权限设置
- 验证文件大小限制

## 📞 获取帮助

- 查看主文档：[README.md](README.md)
- Supabase 文档：[https://supabase.com/docs](https://supabase.com/docs)
- Flutter 文档：[https://flutter.dev/docs](https://flutter.dev/docs)

## ✅ 开发检查清单

- [ ] Flutter 开发环境已安装
- [ ] Supabase 项目已创建
- [ ] 数据库迁移已执行
- [ ] Storage Bucket 已创建
- [ ] 配置文件已创建（且未提交到 Git）
- [ ] 依赖包已安装
- [ ] 应用可以成功运行

祝开发顺利！🎉

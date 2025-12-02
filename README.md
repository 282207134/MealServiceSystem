# 校园点餐系统开发文档

## 📋 项目概述

这是一个基于 Flutter 和 Supabase 的校园点餐系统，适用于学校活动（如校园祭）的移动点餐场景。系统提供类似麦当劳的点餐体验，包含商家管理端和顾客点餐端。

### 主要功能

**商家端（管理者）**
- 菜单管理（添加、编辑、删除商品）
- 订单管理（查看、处理订单）
- 商品分类管理
- 订单状态更新
- 营业时间设置

**顾客端**
- 浏览菜单
- 搜索商品
- 添加到购物车
- 下单支付
- 订单追踪
- 历史订单查看

## 🛠 技术栈

### 前端
- **Flutter** (>= 3.0.0) - 跨平台移动应用开发框架
- **Dart** (>= 3.0.0) - 编程语言

### 后端服务
- **Supabase** - BaaS (Backend as a Service)
  - PostgreSQL 数据库
  - 实时订阅（Real-time subscriptions）
  - 身份认证（Authentication）
  - 存储服务（Storage）
  - Row Level Security (RLS)

### 状态管理
- **Riverpod** / **Provider** / **Bloc** (推荐 Riverpod)

### 主要依赖包
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

## 🏗 系统架构

### 整体架构图

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App                          │
├──────────────────┬──────────────────────────────────────┤
│   顾客端 App      │        商家管理端 App                  │
│  (Customer)      │        (Merchant)                    │
└──────────────────┴──────────────────────────────────────┘
                          ↓ ↑
                    Supabase SDK
                          ↓ ↑
┌─────────────────────────────────────────────────────────┐
│                   Supabase Backend                      │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  PostgreSQL  │  │     Auth     │  │   Storage    │  │
│  │   Database   │  │   Service    │  │   Service    │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│  ┌──────────────┐  ┌──────────────┐                    │
│  │  Real-time   │  │     RLS      │                    │
│  │ Subscriptions│  │   Policies   │                    │
│  └──────────────┘  └──────────────┘                    │
└─────────────────────────────────────────────────────────┘
```

### 应用层架构

采用 **Clean Architecture** 模式：

```
lib/
├── core/                    # 核心功能
│   ├── config/              # 配置文件
│   ├── constants/           # 常量定义
│   ├── theme/               # 主题配置
│   └── utils/               # 工具类
├── data/                    # 数据层
│   ├── models/              # 数据模型
│   ├── repositories/        # 数据仓库实现
│   └── datasources/         # 数据源（Supabase）
├── domain/                  # 业务逻辑层
│   ├── entities/            # 业务实体
│   ├── repositories/        # 仓库接口
│   └── usecases/            # 用例
├── presentation/            # 展示层
│   ├── providers/           # 状态管理
│   ├── screens/             # 页面
│   ├── widgets/             # 组件
│   └── router/              # 路由配置
└── main.dart                # 应用入口
```

## 📊 数据库设计

### ER 图

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│    users     │         │   merchants  │         │  categories  │
├──────────────┤         ├──────────────┤         ├──────────────┤
│ id (PK)      │         │ id (PK)      │         │ id (PK)      │
│ email        │         │ user_id (FK) │         │ merchant_id  │
│ role         │    ┌───→│ name         │    ┌───→│ name         │
│ created_at   │    │    │ description  │    │    │ display_order│
└──────────────┘    │    │ avatar_url   │    │    │ created_at   │
                    │    │ is_active    │    │    └──────────────┘
                    │    │ created_at   │    │
                    │    └──────────────┘    │
                    │                        │
┌──────────────┐    │    ┌──────────────┐   │
│   products   │←───┼────│              │   │
├──────────────┤    │    │              │   │
│ id (PK)      │    │    └──────────────┘   │
│ merchant_id  │────┘                       │
│ category_id  │────────────────────────────┘
│ name         │
│ description  │
│ price        │
│ image_url    │
│ is_available │
│ created_at   │
└──────────────┘
       │
       │
       ↓
┌──────────────┐         ┌──────────────┐
│ order_items  │         │    orders    │
├──────────────┤         ├──────────────┤
│ id (PK)      │    ┌───→│ id (PK)      │
│ order_id (FK)│────┘    │ user_id (FK) │
│ product_id   │         │ merchant_id  │
│ quantity     │         │ total_amount │
│ unit_price   │         │ status       │
│ subtotal     │         │ note         │
└──────────────┘         │ created_at   │
                         │ updated_at   │
                         └──────────────┘
```

### 数据库表结构

#### 1. users (用户表)
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('customer', 'merchant', 'admin')),
  full_name TEXT,
  phone TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 2. merchants (商家表)
```sql
CREATE TABLE merchants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  avatar_url TEXT,
  cover_image_url TEXT,
  is_active BOOLEAN DEFAULT true,
  opening_hours JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 3. categories (分类表)
```sql
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id UUID REFERENCES merchants(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 4. products (商品表)
```sql
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id UUID REFERENCES merchants(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
  image_url TEXT,
  is_available BOOLEAN DEFAULT true,
  stock_quantity INTEGER,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 5. orders (订单表)
```sql
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_number TEXT UNIQUE NOT NULL,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  merchant_id UUID REFERENCES merchants(id) ON DELETE CASCADE,
  total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
  status TEXT NOT NULL CHECK (status IN ('pending', 'confirmed', 'preparing', 'ready', 'completed', 'cancelled')),
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 6. order_items (订单项表)
```sql
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE RESTRICT,
  product_name TEXT NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
  subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal >= 0),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 索引优化

```sql
-- 商家查询优化
CREATE INDEX idx_merchants_user_id ON merchants(user_id);
CREATE INDEX idx_merchants_is_active ON merchants(is_active);

-- 商品查询优化
CREATE INDEX idx_products_merchant_id ON products(merchant_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_is_available ON products(is_available);

-- 订单查询优化
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_merchant_id ON orders(merchant_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);

-- 订单项查询优化
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
```

### Row Level Security (RLS) 策略

```sql
-- 启用 RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE merchants ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Users 策略
CREATE POLICY "Users can view their own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own data"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- Merchants 策略
CREATE POLICY "Anyone can view active merchants"
  ON merchants FOR SELECT
  USING (is_active = true);

CREATE POLICY "Merchants can update their own data"
  ON merchants FOR UPDATE
  USING (user_id = auth.uid());

-- Products 策略
CREATE POLICY "Anyone can view available products"
  ON products FOR SELECT
  USING (is_available = true);

CREATE POLICY "Merchants can manage their products"
  ON products FOR ALL
  USING (
    merchant_id IN (
      SELECT id FROM merchants WHERE user_id = auth.uid()
    )
  );

-- Orders 策略
CREATE POLICY "Users can view their own orders"
  ON orders FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Merchants can view their orders"
  ON orders FOR SELECT
  USING (
    merchant_id IN (
      SELECT id FROM merchants WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create orders"
  ON orders FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Merchants can update their orders"
  ON orders FOR UPDATE
  USING (
    merchant_id IN (
      SELECT id FROM merchants WHERE user_id = auth.uid()
    )
  );
```

## 🔌 API 设计

### Supabase 客户端调用示例

#### 1. 商家管理

```dart
// 获取商家信息
Future<Merchant?> getMerchant(String merchantId) async {
  final response = await supabase
    .from('merchants')
    .select('*')
    .eq('id', merchantId)
    .single();
  
  return Merchant.fromJson(response);
}

// 更新商家信息
Future<void> updateMerchant(String merchantId, Map<String, dynamic> data) async {
  await supabase
    .from('merchants')
    .update(data)
    .eq('id', merchantId);
}
```

#### 2. 商品管理

```dart
// 获取商品列表
Future<List<Product>> getProducts({String? merchantId, String? categoryId}) async {
  var query = supabase
    .from('products')
    .select('*, categories(*)')
    .eq('is_available', true)
    .order('display_order');
  
  if (merchantId != null) {
    query = query.eq('merchant_id', merchantId);
  }
  
  if (categoryId != null) {
    query = query.eq('category_id', categoryId);
  }
  
  final response = await query;
  return (response as List).map((e) => Product.fromJson(e)).toList();
}

// 添加商品
Future<Product> addProduct(Product product) async {
  final response = await supabase
    .from('products')
    .insert(product.toJson())
    .select()
    .single();
  
  return Product.fromJson(response);
}

// 更新商品
Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
  await supabase
    .from('products')
    .update(data)
    .eq('id', productId);
}

// 删除商品
Future<void> deleteProduct(String productId) async {
  await supabase
    .from('products')
    .delete()
    .eq('id', productId);
}
```

#### 3. 订单管理

```dart
// 创建订单
Future<Order> createOrder(Order order, List<OrderItem> items) async {
  // 使用数据库事务
  final orderResponse = await supabase
    .from('orders')
    .insert(order.toJson())
    .select()
    .single();
  
  final orderId = orderResponse['id'];
  
  final itemsData = items.map((item) {
    return {...item.toJson(), 'order_id': orderId};
  }).toList();
  
  await supabase
    .from('order_items')
    .insert(itemsData);
  
  return Order.fromJson(orderResponse);
}

// 获取订单列表（顾客）
Future<List<Order>> getUserOrders(String userId) async {
  final response = await supabase
    .from('orders')
    .select('*, order_items(*, products(*))')
    .eq('user_id', userId)
    .order('created_at', ascending: false);
  
  return (response as List).map((e) => Order.fromJson(e)).toList();
}

// 获取订单列表（商家）
Future<List<Order>> getMerchantOrders(String merchantId, {String? status}) async {
  var query = supabase
    .from('orders')
    .select('*, order_items(*, products(*)), users(*)')
    .eq('merchant_id', merchantId)
    .order('created_at', ascending: false);
  
  if (status != null) {
    query = query.eq('status', status);
  }
  
  final response = await query;
  return (response as List).map((e) => Order.fromJson(e)).toList();
}

// 更新订单状态
Future<void> updateOrderStatus(String orderId, String status) async {
  await supabase
    .from('orders')
    .update({
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    })
    .eq('id', orderId);
}
```

#### 4. 实时订阅

```dart
// 商家监听新订单
StreamSubscription subscribeToNewOrders(String merchantId, Function(Order) onNewOrder) {
  return supabase
    .from('orders')
    .stream(primaryKey: ['id'])
    .eq('merchant_id', merchantId)
    .listen((data) {
      for (var record in data) {
        onNewOrder(Order.fromJson(record));
      }
    });
}

// 顾客监听订单状态更新
StreamSubscription subscribeToOrderUpdates(String orderId, Function(Order) onUpdate) {
  return supabase
    .from('orders')
    .stream(primaryKey: ['id'])
    .eq('id', orderId)
    .listen((data) {
      if (data.isNotEmpty) {
        onUpdate(Order.fromJson(data.first));
      }
    });
}
```

#### 5. 图片上传

```dart
// 上传商品图片
Future<String> uploadProductImage(String merchantId, File imageFile) async {
  final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
  final filePath = 'merchants/$merchantId/products/$fileName';
  
  await supabase.storage
    .from('product-images')
    .upload(filePath, imageFile);
  
  final imageUrl = supabase.storage
    .from('product-images')
    .getPublicUrl(filePath);
  
  return imageUrl;
}
```

## 🎨 UI/UX 设计指南

### 颜色方案

```dart
// colors.dart 文件示例
class AppColors {
  static const primary = Color(0xFFFF6B6B);      // 主题色（红色）
  static const secondary = Color(0xFF4ECDC4);    // 辅助色（青色）
  static const accent = Color(0xFFFFE66D);       // 强调色（黄色）
  
  static const textPrimary = Color(0xFF2D3436);
  static const textSecondary = Color(0xFF636E72);
  static const textLight = Color(0xFFB2BEC3);
  
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const error = Color(0xFFE74C3C);
  static const success = Color(0xFF27AE60);
  
  // 订单状态颜色
  static const statusPending = Color(0xFFF39C12);
  static const statusConfirmed = Color(0xFF3498DB);
  static const statusPreparing = Color(0xFF9B59B6);
  static const statusReady = Color(0xFF27AE60);
  static const statusCompleted = Color(0xFF95A5A6);
  static const statusCancelled = Color(0xFFE74C3C);
}
```

### 主要页面结构

#### 顾客端页面

1. **启动页 (Splash Screen)**
2. **登录/注册页 (Auth Screen)**
3. **主页 (Home Screen)**
   - 商家列表
   - 搜索功能
   - 推荐商品
4. **菜单页 (Menu Screen)**
   - 商品分类
   - 商品列表
   - 商品详情
5. **购物车页 (Cart Screen)**
   - 商品列表
   - 数量调整
   - 订单备注
6. **订单确认页 (Checkout Screen)**
7. **订单列表页 (Orders Screen)**
8. **订单详情页 (Order Detail Screen)**
   - 实时状态更新
9. **个人中心页 (Profile Screen)**

#### 商家端页面

1. **登录页 (Merchant Login)**
2. **仪表盘 (Dashboard)**
   - 今日订单统计
   - 待处理订单
   - 营业状态切换
3. **订单管理页 (Order Management)**
   - 订单列表（按状态筛选）
   - 订单详情
   - 状态更新
4. **菜单管理页 (Menu Management)**
   - 分类管理
   - 商品列表
   - 添加/编辑商品
5. **商家设置页 (Settings)**
   - 商家信息编辑
   - 营业时间设置

### 组件设计

```dart
// 商品卡片组件
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 商品名称
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  // 商品描述
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  // 价格和添加按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '¥${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle),
                        color: AppColors.primary,
                        onPressed: () {
                          // 添加到购物车
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 订单状态标签组件
class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
  
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.statusPending;
      case OrderStatus.confirmed:
        return AppColors.statusConfirmed;
      case OrderStatus.preparing:
        return AppColors.statusPreparing;
      case OrderStatus.ready:
        return AppColors.statusReady;
      case OrderStatus.completed:
        return AppColors.statusCompleted;
      case OrderStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }
  
  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return '待确认';
      case OrderStatus.confirmed:
        return '已确认';
      case OrderStatus.preparing:
        return '制作中';
      case OrderStatus.ready:
        return '待取餐';
      case OrderStatus.completed:
        return '已完成';
      case OrderStatus.cancelled:
        return '已取消';
    }
  }
}
```

## 🚀 开发环境设置

### 前置要求

- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)
- Android Studio / VS Code
- Git
- Supabase 账号

### 步骤 1: 安装 Flutter

```bash
# macOS (使用 Homebrew)
brew install flutter

# 或下载并解压 Flutter SDK
# https://docs.flutter.dev/get-started/install

# 验证安装
flutter doctor
```

### 步骤 2: 创建 Flutter 项目

```bash
# 创建项目
flutter create food_ordering_app
cd food_ordering_app

# 运行项目
flutter run
```

### 步骤 3: 设置 Supabase

1. 访问 [Supabase](https://supabase.com/) 并创建新项目
2. 获取 API URL 和 anon key
3. 在 Supabase Dashboard 中执行数据库迁移脚本（参见数据库设计章节）
4. 创建 Storage bucket：`product-images`（设置为 public）

### 步骤 4: 配置项目

创建配置文件：

```dart
// lib/core/config/supabase_config.dart
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

**重要：** 将 `supabase_config.dart` 添加到 `.gitignore`

### 步骤 5: 安装依赖

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Supabase
  supabase_flutter: ^2.0.0
  
  # 状态管理
  flutter_riverpod: ^2.4.0
  
  # 路由
  go_router: ^12.0.0
  
  # UI
  cached_network_image: ^3.3.0
  image_picker: ^1.0.0
  
  # 工具
  intl: ^0.18.0
  uuid: ^4.0.0
  equatable: ^2.0.5
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
```

安装依赖：

```bash
flutter pub get
```

### 步骤 6: 初始化 Supabase

```dart
// lib/main.dart
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
      home: SplashScreen(),
    );
  }
}
```

## 📝 开发指南

### 代码结构示例

#### 1. 数据模型

```dart
// lib/data/models/product_model.dart
class Product {
  final String id;
  final String merchantId;
  final String? categoryId;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final int? stockQuantity;
  final DateTime createdAt;
  
  Product({
    required this.id,
    required this.merchantId,
    this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    this.stockQuantity,
    required this.createdAt,
  });
  
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      merchantId: json['merchant_id'],
      categoryId: json['category_id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] ?? true,
      stockQuantity: json['stock_quantity'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant_id': merchantId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'stock_quantity': stockQuantity,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
```

#### 2. Repository

```dart
// lib/data/repositories/product_repository.dart
class ProductRepository {
  final SupabaseClient _supabase;
  
  ProductRepository(this._supabase);
  
  Future<List<Product>> getProducts({
    String? merchantId,
    String? categoryId,
  }) async {
    var query = _supabase
        .from('products')
        .select('*')
        .eq('is_available', true)
        .order('display_order');
    
    if (merchantId != null) {
      query = query.eq('merchant_id', merchantId);
    }
    
    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    
    final response = await query;
    return (response as List)
        .map((json) => Product.fromJson(json))
        .toList();
  }
  
  Future<Product> addProduct(Product product) async {
    final response = await _supabase
        .from('products')
        .insert(product.toJson())
        .select()
        .single();
    
    return Product.fromJson(response);
  }
  
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _supabase
        .from('products')
        .update(data)
        .eq('id', id);
  }
  
  Future<void> deleteProduct(String id) async {
    await _supabase
        .from('products')
        .delete()
        .eq('id', id);
  }
}
```

#### 3. Provider (Riverpod)

```dart
// lib/presentation/providers/product_provider.dart
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return ProductRepository(supabase);
});

final productsProvider = FutureProvider.family<List<Product>, String>((ref, merchantId) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProducts(merchantId: merchantId);
});
```

### 最佳实践

1. **错误处理**
   - 使用 try-catch 处理异步操作
   - 显示友好的错误消息
   - 记录错误日志

2. **性能优化**
   - 使用 `cached_network_image` 缓存图片
   - 实现分页加载
   - 使用 `const` 构造函数

3. **安全性**
   - 不在代码中硬编码敏感信息
   - 使用环境变量
   - 实施 RLS 策略

4. **用户体验**
   - 添加加载指示器
   - 实现下拉刷新
   - 提供反馈动画

## 🧪 测试

### 单元测试示例

```dart
// test/repositories/product_repository_test.dart
void main() {
  group('ProductRepository', () {
    late ProductRepository repository;
    late MockSupabaseClient mockSupabase;
    
    setUp(() {
      mockSupabase = MockSupabaseClient();
      repository = ProductRepository(mockSupabase);
    });
    
    test('getProducts returns list of products', () async {
      // Arrange
      when(mockSupabase.from('products'))
          .thenReturn(mockQueryBuilder);
      
      // Act
      final products = await repository.getProducts();
      
      // Assert
      expect(products, isA<List<Product>>());
    });
  });
}
```

### 运行测试

```bash
# 运行所有测试
flutter test

# 运行特定测试
flutter test test/repositories/product_repository_test.dart

# 生成覆盖率报告
flutter test --coverage
```

## 📦 部署

### Android 部署

```bash
# 生成签名密钥
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 配置 android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<keystore-file-path>

# 构建 APK
flutter build apk --release

# 构建 App Bundle
flutter build appbundle --release
```

### iOS 部署

```bash
# 安装 CocoaPods
cd ios
pod install

# 构建 iOS 应用
flutter build ios --release

# 使用 Xcode 打开项目进行签名和上传
open ios/Runner.xcworkspace
```

## 📋 开发路线图

### Phase 1: 基础功能 (2-3 周)

**Week 1:**
- [x] 项目初始化和环境搭建
- [x] Supabase 数据库设计和创建
- [ ] 用户认证（登录/注册）
- [ ] 基础 UI 框架搭建

**Week 2:**
- [ ] 商家管理功能
  - [ ] 商家信息管理
  - [ ] 菜单分类管理
  - [ ] 商品管理（CRUD）
- [ ] 图片上传功能

**Week 3:**
- [ ] 顾客端功能
  - [ ] 商家列表
  - [ ] 商品浏览
  - [ ] 购物车
  - [ ] 下单功能

### Phase 2: 核心功能 (2 周)

**Week 4:**
- [ ] 订单管理系统
  - [ ] 订单创建和查看
  - [ ] 订单状态流转
  - [ ] 实时订单通知

**Week 5:**
- [ ] 商家端订单处理
- [ ] 订单历史记录
- [ ] 搜索和筛选功能

### Phase 3: 优化和扩展 (1-2 周)

**Week 6:**
- [ ] UI/UX 优化
- [ ] 性能优化
- [ ] 错误处理和日志

**Week 7 (可选):**
- [ ] 统计报表功能
- [ ] 推送通知
- [ ] 多语言支持
- [ ] 深色模式

### Phase 4: 测试和部署 (1 周)

**Week 8:**
- [ ] 单元测试和集成测试
- [ ] 用户验收测试
- [ ] 应用打包和发布
- [ ] 文档完善

## 🔧 常见问题

### Q1: 如何处理离线状态？

使用 `connectivity_plus` 包检测网络状态，并实现本地缓存：

```dart
dependencies:
  connectivity_plus: ^5.0.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

### Q2: 如何实现推送通知？

集成 Firebase Cloud Messaging (FCM)：

```dart
dependencies:
  firebase_messaging: ^14.0.0
  flutter_local_notifications: ^16.0.0
```

### Q3: 如何处理支付功能？

对于校园活动，可以考虑：
- 线下支付（取餐时付款）
- 集成支付宝/微信支付 SDK
- 使用 Stripe 等国际支付网关

### Q4: 如何优化图片加载？

```dart
CachedNetworkImage(
  imageUrl: product.imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  memCacheWidth: 800, // 限制缓存大小
  maxWidthDiskCache: 800,
)
```

## 📚 参考资源

### 官方文档
- [Flutter 官方文档](https://flutter.dev/docs)
- [Supabase 官方文档](https://supabase.com/docs)
- [Dart 官方文档](https://dart.dev/guides)

### 学习资源
- [Flutter 实战](https://book.flutterchina.club/)
- [Supabase 教程](https://supabase.com/docs/guides/getting-started)
- [Riverpod 文档](https://riverpod.dev/)

### 社区
- [Flutter 中文网](https://flutter.cn/)
- [Supabase Discord](https://discord.supabase.com/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

## 📄 License

MIT License

## 👥 贡献

欢迎提交 Issue 和 Pull Request！

---

**最后更新时间：** 2024-11

**文档版本：** 1.0.0

**维护者：** 开发团队

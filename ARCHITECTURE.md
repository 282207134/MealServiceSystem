# 系统架构设计文档

## 📐 架构概览

本文档详细说明校园点餐系统的技术架构、设计模式和最佳实践。

## 🏛️ 整体架构

### 三层架构设计

```
┌─────────────────────────────────────────────────────────┐
│                    展示层 (Presentation)                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   顾客界面    │  │   商家界面    │  │   共享组件    │  │
│  │   Screens    │  │   Screens    │  │   Widgets    │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│         ↓                  ↓                  ↓          │
│  ┌─────────────────────────────────────────────────┐   │
│  │          状态管理层 (Providers/BLoC)            │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                          ↓ ↑
┌─────────────────────────────────────────────────────────┐
│                 业务逻辑层 (Domain Layer)                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   用例类      │  │  业务实体     │  │  仓库接口     │  │
│  │  UseCases    │  │  Entities    │  │ Repositories │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ↓ ↑
┌─────────────────────────────────────────────────────────┐
│                  数据层 (Data Layer)                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ 仓库实现类    │  │   数据模型    │  │   数据源      │  │
│  │ Repos Impl   │  │   Models     │  │ DataSources  │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ↓ ↑
┌─────────────────────────────────────────────────────────┐
│                   后端服务 (Supabase)                    │
│    数据库  |  认证  |  存储  |  实时通信  |  API        │
└─────────────────────────────────────────────────────────┘
```

## 📂 详细目录结构

```
food_ordering_app/
├── lib/
│   ├── core/                          # 核心功能模块
│   │   ├── config/                    # 配置文件
│   │   │   ├── supabase_config.dart   # Supabase 配置（不提交到 Git）
│   │   │   └── app_config.dart        # 应用配置
│   │   ├── constants/                 # 常量定义
│   │   │   ├── app_colors.dart        # 颜色常量
│   │   │   ├── app_strings.dart       # 字符串常量
│   │   │   ├── app_dimensions.dart    # 尺寸常量
│   │   │   └── order_status.dart      # 订单状态枚举
│   │   ├── theme/                     # 主题配置
│   │   │   ├── app_theme.dart         # 应用主题
│   │   │   └── text_styles.dart       # 文字样式
│   │   ├── utils/                     # 工具类
│   │   │   ├── validators.dart        # 表单验证工具
│   │   │   ├── formatters.dart        # 格式化工具（日期、货币等）
│   │   │   ├── logger.dart            # 日志工具
│   │   │   └── extensions.dart        # Dart 扩展方法
│   │   └── error/                     # 错误处理
│   │       ├── exceptions.dart        # 异常定义
│   │       └── failures.dart          # 失败类型定义
│   │
│   ├── domain/                        # 业务逻辑层（领域层）
│   │   ├── entities/                  # 业务实体
│   │   │   ├── user.dart              # 用户实体
│   │   │   ├── merchant.dart          # 商家实体
│   │   │   ├── product.dart           # 商品实体
│   │   │   ├── category.dart          # 分类实体
│   │   │   ├── order.dart             # 订单实体
│   │   │   └── order_item.dart        # 订单项实体
│   │   ├── repositories/              # 仓库接口（抽象）
│   │   │   ├── auth_repository.dart   # 认证仓库接口
│   │   │   ├── merchant_repository.dart  # 商家仓库接口
│   │   │   ├── product_repository.dart   # 商品仓库接口
│   │   │   └── order_repository.dart     # 订单仓库接口
│   │   └── usecases/                  # 用例（业务逻辑）
│   │       ├── auth/                  # 认证相关用例
│   │       │   ├── sign_in_usecase.dart
│   │       │   ├── sign_up_usecase.dart
│   │       │   └── sign_out_usecase.dart
│   │       ├── product/               # 商品相关用例
│   │       │   ├── get_products_usecase.dart
│   │       │   ├── create_product_usecase.dart
│   │       │   └── update_product_usecase.dart
│   │       └── order/                 # 订单相关用例
│   │           ├── create_order_usecase.dart
│   │           ├── get_orders_usecase.dart
│   │           └── update_order_status_usecase.dart
│   │
│   ├── data/                          # 数据层
│   │   ├── models/                    # 数据模型（DTO）
│   │   │   ├── user_model.dart        # 用户模型
│   │   │   ├── merchant_model.dart    # 商家模型
│   │   │   ├── product_model.dart     # 商品模型
│   │   │   ├── category_model.dart    # 分类模型
│   │   │   ├── order_model.dart       # 订单模型
│   │   │   └── order_item_model.dart  # 订单项模型
│   │   ├── repositories/              # 仓库实现
│   │   │   ├── auth_repository_impl.dart
│   │   │   ├── merchant_repository_impl.dart
│   │   │   ├── product_repository_impl.dart
│   │   │   └── order_repository_impl.dart
│   │   └── datasources/               # 数据源
│   │       ├── remote/                # 远程数据源
│   │       │   ├── supabase_auth_datasource.dart
│   │       │   ├── supabase_merchant_datasource.dart
│   │       │   ├── supabase_product_datasource.dart
│   │       │   └── supabase_order_datasource.dart
│   │       └── local/                 # 本地数据源（缓存）
│   │           └── local_cache.dart
│   │
│   ├── presentation/                  # 展示层
│   │   ├── providers/                 # 状态管理（Riverpod）
│   │   │   ├── auth_provider.dart     # 认证状态
│   │   │   ├── user_provider.dart     # 用户信息状态
│   │   │   ├── merchant_provider.dart # 商家状态
│   │   │   ├── products_provider.dart # 商品列表状态
│   │   │   ├── cart_provider.dart     # 购物车状态
│   │   │   └── orders_provider.dart   # 订单状态
│   │   │
│   │   ├── screens/                   # 页面
│   │   │   ├── splash/                # 启动页
│   │   │   │   └── splash_screen.dart
│   │   │   ├── auth/                  # 认证相关页面
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   └── widgets/           # 认证页面组件
│   │   │   ├── customer/              # 顾客端页面
│   │   │   │   ├── home/
│   │   │   │   │   ├── home_screen.dart
│   │   │   │   │   └── widgets/
│   │   │   │   ├── menu/
│   │   │   │   │   ├── menu_screen.dart
│   │   │   │   │   ├── product_detail_screen.dart
│   │   │   │   │   └── widgets/
│   │   │   │   ├── cart/
│   │   │   │   │   ├── cart_screen.dart
│   │   │   │   │   └── widgets/
│   │   │   │   ├── orders/
│   │   │   │   │   ├── orders_screen.dart
│   │   │   │   │   ├── order_detail_screen.dart
│   │   │   │   │   └── widgets/
│   │   │   │   └── profile/
│   │   │   │       ├── profile_screen.dart
│   │   │   │       └── widgets/
│   │   │   └── merchant/              # 商家端页面
│   │   │       ├── dashboard/
│   │   │       │   ├── dashboard_screen.dart
│   │   │       │   └── widgets/
│   │   │       ├── menu_management/
│   │   │       │   ├── menu_management_screen.dart
│   │   │       │   ├── add_product_screen.dart
│   │   │       │   ├── edit_product_screen.dart
│   │   │       │   └── widgets/
│   │   │       ├── order_management/
│   │   │       │   ├── order_management_screen.dart
│   │   │       │   ├── order_detail_screen.dart
│   │   │       │   └── widgets/
│   │   │       └── settings/
│   │   │           ├── settings_screen.dart
│   │   │           └── widgets/
│   │   │
│   │   ├── widgets/                   # 共享组件
│   │   │   ├── common/                # 通用组件
│   │   │   │   ├── custom_button.dart
│   │   │   │   ├── custom_text_field.dart
│   │   │   │   ├── loading_indicator.dart
│   │   │   │   └── error_widget.dart
│   │   │   ├── product/               # 商品相关组件
│   │   │   │   ├── product_card.dart
│   │   │   │   └── product_grid.dart
│   │   │   └── order/                 # 订单相关组件
│   │   │       ├── order_card.dart
│   │   │       └── order_status_badge.dart
│   │   │
│   │   └── router/                    # 路由配置
│   │       └── app_router.dart        # 应用路由
│   │
│   └── main.dart                      # 应用入口
│
├── test/                              # 测试文件
│   ├── unit/                          # 单元测试
│   ├── widget/                        # 组件测试
│   └── integration/                   # 集成测试
│
├── assets/                            # 资源文件
│   ├── images/                        # 图片
│   ├── icons/                         # 图标
│   └── fonts/                         # 字体
│
├── pubspec.yaml                       # 项目依赖配置
├── analysis_options.yaml              # 代码分析配置
└── README.md                          # 项目说明文档
```

## 🔄 数据流向

### 1. 顾客下单流程

```
用户点击下单按钮
    ↓
[UI Layer] CartScreen
    ↓
调用 Provider
    ↓
[Provider] CartProvider.checkout()
    ↓
调用 UseCase
    ↓
[UseCase] CreateOrderUseCase.call()
    ↓
调用 Repository 接口
    ↓
[Repository] OrderRepository.createOrder()
    ↓
调用 DataSource
    ↓
[DataSource] SupabaseOrderDataSource.createOrder()
    ↓
发送请求到 Supabase
    ↓
数据库写入成功
    ↓
返回订单数据
    ↓
更新 UI 状态
    ↓
显示订单确认页面
```

### 2. 商家接收订单流程

```
Supabase 触发 Realtime 事件
    ↓
[DataSource] 接收新订单事件
    ↓
[Repository] 处理订单数据
    ↓
[Provider] OrdersProvider 更新状态
    ↓
[UI] 自动刷新订单列表
    ↓
显示新订单提醒
```

## 🎯 设计模式

### 1. Repository 模式

**目的：** 将数据访问逻辑与业务逻辑分离

```dart
// 接口定义（domain层）
abstract class ProductRepository {
  Future<List<Product>> getProducts(String merchantId);
  Future<Product> createProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String productId);
}

// 实现类（data层）
class ProductRepositoryImpl implements ProductRepository {
  final SupabaseProductDataSource _dataSource;
  
  ProductRepositoryImpl(this._dataSource);
  
  @override
  Future<List<Product>> getProducts(String merchantId) async {
    // 从数据源获取数据
    final models = await _dataSource.getProducts(merchantId);
    // 转换为领域实体
    return models.map((m) => m.toEntity()).toList();
  }
  
  // ... 其他方法实现
}
```

### 2. Provider 模式（状态管理）

**目的：** 管理应用状态，实现响应式UI更新

```dart
// 使用 Riverpod 进行状态管理

// 1. 提供依赖注入
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final dataSource = SupabaseProductDataSource(supabase);
  return ProductRepositoryImpl(dataSource);
});

// 2. 创建状态Provider
final productsProvider = StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return ProductsNotifier(repository);
});

// 3. 状态管理类
class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ProductRepository _repository;
  
  ProductsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProducts();
  }
  
  Future<void> loadProducts() async {
    state = const AsyncValue.loading();
    try {
      final products = await _repository.getProducts();
      state = AsyncValue.data(products);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// 4. 在UI中使用
class ProductsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsProvider);
    
    return productsState.when(
      data: (products) => ProductsList(products: products),
      loading: () => LoadingIndicator(),
      error: (error, stack) => ErrorWidget(error: error),
    );
  }
}
```

### 3. UseCase 模式

**目的：** 封装单一业务逻辑，提高代码可测试性

```dart
// UseCase 基类
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

// 具体 UseCase 实现
class CreateOrderUseCase extends UseCase<Order, CreateOrderParams> {
  final OrderRepository _orderRepository;
  final ProductRepository _productRepository;
  
  CreateOrderUseCase(this._orderRepository, this._productRepository);
  
  @override
  Future<Order> call(CreateOrderParams params) async {
    // 1. 验证商品可用性
    for (var item in params.items) {
      final product = await _productRepository.getProduct(item.productId);
      if (!product.isAvailable) {
        throw ProductNotAvailableException(product.name);
      }
    }
    
    // 2. 计算总金额
    final totalAmount = params.items.fold<double>(
      0, 
      (sum, item) => sum + (item.quantity * item.unitPrice),
    );
    
    // 3. 创建订单
    return await _orderRepository.createOrder(
      userId: params.userId,
      merchantId: params.merchantId,
      items: params.items,
      totalAmount: totalAmount,
      note: params.note,
    );
  }
}

// 参数类
class CreateOrderParams {
  final String userId;
  final String merchantId;
  final List<OrderItem> items;
  final String? note;
  
  CreateOrderParams({
    required this.userId,
    required this.merchantId,
    required this.items,
    this.note,
  });
}
```

### 4. Factory 模式

**目的：** 统一创建对象的方式

```dart
// 模型工厂
class ProductModel {
  final String id;
  final String name;
  final double price;
  
  ProductModel({
    required this.id,
    required this.name,
    required this.price,
  });
  
  // 从 JSON 创建
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }
  
  // 从实体创建
  factory ProductModel.fromEntity(Product entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
    );
  }
  
  // 转换为实体
  Product toEntity() {
    return Product(
      id: id,
      name: name,
      price: price,
    );
  }
  
  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }
}
```

## 🔐 安全性设计

### 1. Row Level Security (RLS)

在 Supabase 中配置 RLS 策略，确保数据安全：

```sql
-- 用户只能查看自己的订单
CREATE POLICY "用户查看自己的订单"
  ON orders FOR SELECT
  USING (auth.uid() = user_id);

-- 商家只能修改自己的订单状态
CREATE POLICY "商家修改自己的订单"
  ON orders FOR UPDATE
  USING (
    merchant_id IN (
      SELECT id FROM merchants WHERE user_id = auth.uid()
    )
  );
```

### 2. 认证令牌管理

```dart
// 自动刷新 Token
class AuthService {
  final SupabaseClient _supabase;
  
  AuthService(this._supabase) {
    // 监听认证状态变化
    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.tokenRefreshed) {
        // Token 已刷新，更新本地存储
        _updateLocalToken(data.session?.accessToken);
      } else if (event == AuthChangeEvent.signedOut) {
        // 用户登出，清理本地数据
        _clearLocalData();
      }
    });
  }
  
  // 更新本地 Token
  void _updateLocalToken(String? token) {
    // 实现 Token 存储逻辑
  }
  
  // 清理本地数据
  void _clearLocalData() {
    // 实现数据清理逻辑
  }
}
```

### 3. 输入验证

```dart
// 表单验证器
class Validators {
  // 邮箱验证
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱地址';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return '请输入有效的邮箱地址';
    }
    
    return null;
  }
  
  // 密码验证
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    
    if (value.length < 6) {
      return '密码长度不能少于6位';
    }
    
    return null;
  }
  
  // 价格验证
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入价格';
    }
    
    final price = double.tryParse(value);
    if (price == null || price < 0) {
      return '请输入有效的价格';
    }
    
    return null;
  }
}
```

## ⚡ 性能优化

### 1. 图片缓存

```dart
// 使用 CachedNetworkImage 缓存网络图片
CachedNetworkImage(
  imageUrl: product.imageUrl,
  // 内存缓存限制
  memCacheWidth: 800,
  memCacheHeight: 800,
  // 占位符
  placeholder: (context, url) => const ShimmerLoading(),
  // 错误处理
  errorWidget: (context, url, error) => const Icon(Icons.error),
  // 淡入动画
  fadeInDuration: const Duration(milliseconds: 300),
)
```

### 2. 列表优化

```dart
// 使用 ListView.builder 进行懒加载
ListView.builder(
  // 仅构建可见项
  itemCount: products.length,
  // 添加缓存范围
  cacheExtent: 500.0,
  itemBuilder: (context, index) {
    final product = products[index];
    return ProductCard(product: product);
  },
)

// 实现分页加载
class ProductsList extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProductsList> createState() => _ProductsListState();
}

class _ProductsListState extends ConsumerState<ProductsList> {
  final _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }
  
  void _onScroll() {
    // 滚动到底部时加载更多
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.9) {
      ref.read(productsProvider.notifier).loadMore();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: products.length,
      itemBuilder: (context, index) => ProductCard(product: products[index]),
    );
  }
}
```

### 3. 状态管理优化

```dart
// 使用 select 仅监听需要的状态
Consumer(
  builder: (context, ref, child) {
    // 仅在商品列表变化时重建，忽略其他状态变化
    final products = ref.watch(
      productsProvider.select((state) => state.products),
    );
    
    return ProductsList(products: products);
  },
)

// 使用 family 和 autoDispose 避免内存泄漏
final productProvider = FutureProvider.autoDispose.family<Product, String>(
  (ref, productId) async {
    final repository = ref.watch(productRepositoryProvider);
    return repository.getProduct(productId);
  },
);
```

## 🧪 测试策略

### 1. 单元测试

```dart
// 测试 Repository
void main() {
  group('ProductRepository', () {
    late ProductRepository repository;
    late MockProductDataSource mockDataSource;
    
    setUp(() {
      mockDataSource = MockProductDataSource();
      repository = ProductRepositoryImpl(mockDataSource);
    });
    
    test('获取商品列表成功', () async {
      // Arrange（准备）
      final mockProducts = [
        ProductModel(id: '1', name: '测试商品', price: 10.0),
      ];
      when(() => mockDataSource.getProducts(any()))
          .thenAnswer((_) async => mockProducts);
      
      // Act（执行）
      final result = await repository.getProducts('merchant-1');
      
      // Assert（断言）
      expect(result, isA<List<Product>>());
      expect(result.length, 1);
      verify(() => mockDataSource.getProducts('merchant-1')).called(1);
    });
  });
}
```

### 2. Widget 测试

```dart
// 测试 UI 组件
void main() {
  testWidgets('ProductCard 显示商品信息', (tester) async {
    // 准备测试数据
    final product = Product(
      id: '1',
      name: '测试商品',
      price: 10.0,
      imageUrl: 'https://example.com/image.jpg',
    );
    
    // 构建 Widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCard(product: product),
        ),
      ),
    );
    
    // 验证显示
    expect(find.text('测试商品'), findsOneWidget);
    expect(find.text('¥10.00'), findsOneWidget);
  });
}
```

## 📊 监控和日志

### 日志系统

```dart
// 统一的日志工具
class AppLogger {
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      log('🐛 DEBUG: $message', error: error, stackTrace: stackTrace);
    }
  }
  
  static void info(String message) {
    log('ℹ️ INFO: $message');
  }
  
  static void warning(String message, [dynamic error]) {
    log('⚠️ WARNING: $message', error: error);
  }
  
  static void error(String message, dynamic error, [StackTrace? stackTrace]) {
    log('❌ ERROR: $message', error: error, stackTrace: stackTrace);
    // 可以在这里集成错误追踪服务（如 Sentry）
  }
}
```

## 🔄 持续集成/持续部署 (CI/CD)

建议使用 GitHub Actions 或 GitLab CI 进行自动化构建和测试。

```yaml
# .github/workflows/flutter.yml 示例
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      
  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release
```

## 📝 代码规范

### 命名约定

- **类名：** PascalCase（如：`ProductRepository`）
- **方法名：** camelCase（如：`getProducts`）
- **常量：** lowerCamelCase（如：`primaryColor`）
- **私有成员：** 前缀下划线（如：`_supabase`）

### 文件组织

- 每个文件只包含一个主要的类或组件
- 相关的类可以放在同一个文件中（如：Model 和 Entity）
- 使用 barrel files (index.dart) 简化导入

### 注释规范

```dart
/// 商品仓库接口
/// 
/// 提供商品的增删改查功能
abstract class ProductRepository {
  /// 获取指定商家的所有商品
  /// 
  /// [merchantId] 商家ID
  /// 返回商品列表
  Future<List<Product>> getProducts(String merchantId);
  
  /// 创建新商品
  /// 
  /// [product] 商品信息
  /// 返回创建成功的商品
  /// 抛出 [ProductException] 如果创建失败
  Future<Product> createProduct(Product product);
}
```

## 🚀 部署清单

发布前检查清单：

- [ ] 所有测试通过
- [ ] 代码已格式化（`flutter format .`）
- [ ] 代码分析无警告（`flutter analyze`）
- [ ] 已移除 debug 日志
- [ ] 已更新版本号
- [ ] 已签名 APK/IPA
- [ ] 已测试主要功能流程
- [ ] 已准备应用商店截图和描述

---

**文档版本：** 1.0.0  
**最后更新：** 2024-11

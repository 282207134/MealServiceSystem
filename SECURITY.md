# 🔐 安全最佳实践指南

本文档汇总校园点餐系统中的安全设计原则、实践策略、以及具体实现细节，帮助开发者构建安全可靠的应用。

---

## 📋 目录

- [总体安全原则](#总体安全原则)
- [Supabase 安全策略](#supabase-安全策略)
- [认证与授权](#认证与授权)
- [数据传输与存储安全](#数据传输与存储安全)
- [输入验证与防护](#输入验证与防护)
- [代码安全](#代码安全)
- [依赖和第三方服务安全](#依赖和第三方服务安全)
- [应用内安全机制](#应用内安全机制)
- [安全测试与监控](#安全测试与监控)
- [安全响应与应急预案](#安全响应与应急预案)
- [安全检查清单](#安全检查清单)

---

## 总体安全原则

1. **最小权限原则（Least Privilege）**
   - 确保每个用户、服务、API 只具备完成自身任务所需的最少权限

2. **零信任架构（Zero Trust）**
   - 默认不信任任何请求，通过认证和策略判断是否允许访问

3. **数据加密**
   - 传输层强制使用 HTTPS/TLS
   - 存储层对敏感数据进行加密

4. **可审计性**
   - 关键操作必须有日志记录，便于追踪和审计

5. **安全默认值**
   - 默认禁用敏感操作，必须明确启用

6. **定期更新**
   - 保持 Supabase、依赖库、Flutter SDK 等更新至最新稳定版本

---

## Supabase 安全策略

### 1. Row Level Security (RLS)

RLS 是 Supabase 中的核心安全机制，可确保用户只能访问属于自己的数据。

#### 1.1 启用 RLS

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE merchants ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
```

#### 1.2 RLS 策略示例

```sql
-- 用户只能查看和更新自己的数据
CREATE POLICY "users_self_access"
ON users FOR ALL
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- 商家只能管理自己的商品
CREATE POLICY "merchant_product_management"
ON products FOR ALL
USING (
  merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
);

-- 顾客只能查看自己的订单
CREATE POLICY "customer_view_orders"
ON orders FOR SELECT
USING (user_id = auth.uid());
```

### 2. API Key 安全

#### 2.1 区分密钥用途

| 密钥类型 | 用途 | 是否可在客户端使用 | 说明 |
|----------|------|------------------|------|
| anon (public) key | 供客户端使用 | ✅ | 权限最小，仅限公共操作 |
| service_role key | 供服务器使用 | ❌ | 权限较大，禁止暴露在客户端 |

#### 2.2 安全存储密钥

- **Flutter 客户端**：
  - 只使用 `anon` key
  - 放在 `supabase_config.dart` 中
  - 文件不提交到 Git

- **服务端或 CI/CD**：
  - 使用环境变量存储 `service_role` key
  - 不写入代码库

### 3. 网络访问控制

#### 3.1 限制 API 访问来源（可选）

在 Supabase 中配置 `Allowed Origins`：
- 开发环境：`http://localhost:3000`
- 生产环境：`https://app.example.com`

#### 3.2 数据库连接限制

- 使用 Supabase 提供的托管数据库，默认启用防火墙
- 禁止直接访问数据库端口

### 4. Storage 安全

#### 4.1 Bucket 权限

- 商品图片：`product-images`（Public）
- 用户头像：`user-avatars`（可选，建议 Private）

#### 4.2 上传策略

```sql
CREATE POLICY "authenticated_upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'product-images');
```

#### 4.3 删除策略

```sql
CREATE POLICY "owner_delete"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'product-images'
  AND auth.uid()::text = owner
);
```

---

## 认证与授权

### 1. 认证流程

1. 用户提交邮箱和密码
2. Supabase Auth 验证用户
3. 返回 JWT Token（包含用户信息）
4. 客户端存储 Token（安全地）
5. 每次请求附带 Token

### 2. 密码安全策略

- 最小长度：6
- 建议使用密码强度提示（大小写字母、数字、特殊字符）

### 3. 令牌管理

```dart
supabase.auth.onAuthStateChange.listen((data) {
  final event = data.event;
  if (event == AuthChangeEvent.tokenRefreshed) {
    // Token 自动刷新
    saveToken(data.session?.accessToken);
  } else if (event == AuthChangeEvent.signedOut) {
    // 清理本地数据
    clearLocalData();
  }
});
```

### 4. 多因素认证（MFA）

- 目前 Supabase Auth 支持 TOTP（计划中）
- 可集成第三方（如 Auth0）实现更高级的认证

---

## 数据传输与存储安全

### 1. HTTPS 强制

- Flutter 客户端在 Android 和 iOS 上默认使用 HTTPS
- 如果使用 Web 端，确保部署在支持 HTTPS 的平台上（如 Firebase Hosting）

### 2. 数据加密

- Supabase 默认使用 TLS 加密传输
- 对于敏感数据（如用户地址、手机号），可在数据库中进行加密存储

### 3. 本地存储安全

- 使用 `flutter_secure_storage` 存储 Token
- 不要将敏感数据存储在 SharedPreferences 中

```dart
final storage = FlutterSecureStorage();
await storage.write(key: 'token', value: token);
```

---

## 输入验证与防护

### 1. 客户端验证

```dart
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return '请输入邮箱地址';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}
');
    if (!regex.hasMatch(value)) return '邮箱格式不正确';
    return null;
  }
}
```

### 2. 服务端验证

使用 Supabase 数据库约束：

```sql
ALTER TABLE users ADD CONSTRAINT email_format CHECK (email LIKE '%@%.%');
ALTER TABLE products ADD CONSTRAINT price_positive CHECK (price >= 0);
```

### 3. 防 SQL 注入

- 使用 Supabase SDK 自动参数化
- 避免拼接 SQL 字符串

### 4. 防 XSS 攻击

- 在展示用户生成内容时进行转义
- 使用 Flutter 的 `Text` 组件自动处理

---

## 代码安全

### 1. API 密钥管理

- `supabase_config.dart` 不提交到 Git
- 在 `.gitignore` 中添加：

```
lib/core/config/supabase_config.dart
.env
.env.local
```

### 2. 代码审查

- 所有代码变更必须经过 Code Review
- 使用 lint 工具提高代码质量

### 3. 日志管理

- 日志中不可包含敏感数据
- 使用环境变量控制日志级别

```dart
class AppLogger {
  static final _logger = Logger(level: kReleaseMode ? Level.warning : Level.debug);
}
```

---

## 依赖和第三方服务安全

### 1. 依赖管理

- 定期运行 `flutter pub outdated`
- 避免使用未维护或低下载量的包

### 2. 许可证检查

- 确认所有依赖符合开源许可证要求

### 3. 第三方服务安全

- OAuth 登录：使用官方 SDK
go
- 支付服务：遵循 PCI-DSS 规范

---

## 应用内安全机制

### 1. 防重放攻击

- 在请求中添加时间戳和随机数

### 2. 防止调试

```dart
assert(() {
  debugPrint('调试模式开启');
  return true;
}());
```

### 3. 防止反编译

- 混淆 Android 代码（ProGuard）
- 混淆 iOS 代码（Bitcode）

---

## 安全测试与监控

### 1. 安全测试

- 单元测试：验证数据验证逻辑
- 集成测试：模拟攻击场景
- 渗透测试：使用 OWASP ZAP

### 2. 监控

- 错误日志（Sentry）
- 性能监控（Firebase Crashlytics）
- 用户行为分析（Mixpanel）

---

## 安全响应与应急预案

### 1. 安全事件响应流程

1. **发现问题**：通过监控或用户反馈
2. **确认问题**：重现并分析
3. **紧急修复**：发布补丁
4. **通知用户**：说明影响和解决方案
5. **总结复盘**：更新安全策略

### 2. 备份与恢复

- 定期备份数据库和文件
- 制定恢复流程

### 3. 法律合规

- 符合 GDPR、CCPA 等数据保护法规
- 制定隐私政策和用户协议

---

## 安全检查清单

| 检查项 | 状态 |
|--------|------|
| RLS 策略已启用且配置正确 | ☐ |
| API 密钥没有暴露在代码库 | ☐ |
| HTTPS 连接 | ☐ |
| 密码强度验证 | ☐ |
| 输入验证 | ☐ |
| 敏感数据加密 | ☐ |
| 日志不包含敏感信息 | ☐ |
| 定期备份 | ☐ |
| 安全事件响应流程 | ☐ |

---

**安全文档版本：** 1.0.0  
**最后更新：** 2024-11  
**维护者：** 安全团队

**建议下一步阅读：**
- [DEPLOYMENT.md](DEPLOYMENT.md)
- [PERFORMANCE.md](PERFORMANCE.md)
- [ARCHITECTURE.md](ARCHITECTURE.md)

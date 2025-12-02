# 📧 邮箱验证配置指南

## ✅ 当前配置状态

根据您的 Supabase Dashboard 截图，您的配置如下：

- ✅ **Email 提供商已启用**
- ✅ **确认电子邮件已开启**

这意味着用户注册后需要验证邮箱才能登录。

---

## 🔍 邮箱验证流程

### 用户注册流程

1. **用户注册**
   ```
   用户填写：邮箱 + 密码
   ↓
   系统发送验证邮件
   ↓
   用户点击邮件中的验证链接
   ↓
   邮箱验证成功，可以登录
   ```

2. **如果未验证**
   - 用户无法登录
   - 会提示"请先验证您的邮箱"

---

## 🧪 开发测试建议

### 方法 1：使用真实邮箱测试（推荐）

1. **注册测试账号**
   - 使用您的真实邮箱（如：your-email@gmail.com）
   - 设置密码

2. **查收验证邮件**
   - 检查收件箱（可能在垃圾邮件中）
   - 点击邮件中的验证链接

3. **登录测试**
   - 使用已验证的邮箱和密码登录

### 方法 2：临时关闭邮箱验证（仅开发阶段）

如果频繁测试不方便，可以临时关闭：

1. **Supabase Dashboard** → **Authentication** → **Settings**
2. 关闭 **"确认电子邮件 (Confirm email)"**
3. 点击 **"保存更改"**

**注意**：生产环境建议保持开启，确保邮箱真实性。

### 方法 3：使用 Supabase 的测试邮箱

Supabase 提供测试邮箱功能（如果可用）：

- 在开发环境中，某些邮件可能不会真正发送
- 可以在 Dashboard → Authentication → Logs 中查看

---

## 📝 邮件模板配置（可选）

### 自定义邮件模板

1. **Supabase Dashboard** → **Authentication** → **Email Templates**

2. **可自定义的模板**：
   - **Confirm signup**（注册确认）
   - **Reset password**（重置密码）
   - **Magic Link**（魔法链接）
   - **Change Email Address**（更改邮箱）

3. **自定义示例**：

```
主题：欢迎注册校园点餐系统！

内容：
您好！

感谢您注册校园点餐系统。

请点击以下链接验证您的邮箱：
{{ .ConfirmationURL }}

如果链接无法点击，请复制以下地址到浏览器：
{{ .ConfirmationURL }}

此链接将在 24 小时后过期。

如果您没有注册此账号，请忽略此邮件。

祝好，
校园点餐系统团队
```

---

## 🔧 代码中的处理

### 注册时处理邮箱验证

```dart
// lib/data/repositories/auth_repository.dart

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
  
  // 检查是否需要邮箱验证
  if (response.user != null && response.session == null) {
    // 需要邮箱验证
    throw Exception('请检查您的邮箱并点击验证链接');
  }
  
  return response;
}
```

### 检查用户是否已验证

```dart
// 检查当前用户邮箱是否已验证
bool isEmailVerified() {
  final user = _supabase.auth.currentUser;
  return user?.emailConfirmedAt != null;
}
```

### 重新发送验证邮件

```dart
// 重新发送验证邮件
Future<void> resendVerificationEmail() async {
  await _supabase.auth.resend(
    type: OtpType.signup,
    email: _supabase.auth.currentUser?.email ?? '',
  );
}
```

---

## ⚠️ 常见问题

### Q1: 收不到验证邮件？

**检查项：**
1. 检查垃圾邮件文件夹
2. 确认邮箱地址拼写正确
3. 检查 Supabase Dashboard → Authentication → Logs
4. 确认邮件服务配置正确

**解决方案：**
- 等待几分钟后重试
- 使用"重新发送验证邮件"功能
- 检查 Supabase 项目的邮件配额

### Q2: 验证链接过期？

**默认过期时间：** 24 小时

**解决方案：**
- 重新注册
- 或使用"重新发送验证邮件"

### Q3: 开发时不想每次都验证？

**临时解决方案：**
1. 关闭"确认电子邮件"开关
2. 或使用测试账号（已验证的）
3. 或配置邮件服务使用测试模式

---

## 🎯 最佳实践

### 开发阶段

- ✅ 可以使用真实邮箱测试完整流程
- ✅ 或临时关闭验证方便快速测试
- ✅ 记录已验证的测试账号

### 生产环境

- ✅ **必须开启邮箱验证**
- ✅ 自定义邮件模板，提升用户体验
- ✅ 配置邮件服务（SMTP）确保邮件送达
- ✅ 添加"重新发送验证邮件"功能
- ✅ 友好的提示信息

---

## 📋 测试清单

完成邮箱验证配置后：

- [ ] 测试注册流程
- [ ] 测试接收验证邮件
- [ ] 测试点击验证链接
- [ ] 测试验证后登录
- [ ] 测试未验证时登录（应该失败）
- [ ] 测试重新发送验证邮件
- [ ] 自定义邮件模板（可选）

---

## 🔗 相关资源

- [Supabase Auth 文档](https://supabase.com/docs/guides/auth)
- [邮箱验证配置](https://supabase.com/docs/guides/auth/auth-email-templates)
- [SMTP 配置](https://supabase.com/docs/guides/auth/auth-smtp)

---

**您的邮箱验证已正确配置！** ✅

现在用户可以注册并验证邮箱后登录系统。


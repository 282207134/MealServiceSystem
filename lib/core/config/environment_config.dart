/// 环境配置
///
/// 使用 `--dart-define` 传入敏感配置，避免将密钥写入代码库
class EnvironmentConfig {
  const EnvironmentConfig._();

  /// Supabase 项目 URL
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  /// Supabase 公共密钥
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'public-anon-key',
  );

  /// 商品图片桶名称
  static const String productImagesBucket = String.fromEnvironment(
    'SUPABASE_PRODUCT_BUCKET',
    defaultValue: 'product-images',
  );

  /// 是否启用实时订阅
  static const bool enableRealtimeSubscription = bool.fromEnvironment(
    'SUPABASE_ENABLE_REALTIME',
    defaultValue: true,
  );
}

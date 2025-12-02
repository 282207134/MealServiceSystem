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

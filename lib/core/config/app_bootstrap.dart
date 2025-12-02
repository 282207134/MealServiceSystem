import 'dart:async';

import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/app_logger.dart';
import 'environment_config.dart';
import 'supabase_config.dart';

/// 负责初始化第三方服务（如 Supabase、日志、缓存等）
class AppBootstrap {
  const AppBootstrap._();

  static final Logger _logger = AppLogger.instance;
  static bool _isSupabaseInitialized = false;

  /// 初始化应用运行所需的所有依赖
  static Future<void> initialize() async {
    await _initializeSupabase();
  }

  static Future<void> _initializeSupabase() async {
    if (_isSupabaseInitialized) {
      return;
    }

    try {
      // 优先使用环境变量，如果未设置则使用配置文件
      const url = EnvironmentConfig.supabaseUrl != 'https://your-project.supabase.co'
          ? EnvironmentConfig.supabaseUrl
          : SupabaseConfig.url;
      
      const anonKey = EnvironmentConfig.supabaseAnonKey != 'public-anon-key'
          ? EnvironmentConfig.supabaseAnonKey
          : SupabaseConfig.anonKey;

      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        debug: true,
      );
      _isSupabaseInitialized = true;
      _logger.i('Supabase 初始化完成');
    } catch (error) {
      _logger.w('Supabase 初始化失败（应用将使用离线模式）：$error');
    }
  }
}

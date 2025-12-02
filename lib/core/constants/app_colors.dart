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

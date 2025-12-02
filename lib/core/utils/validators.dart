class Validators {
  const Validators._();

  static bool isValidEmail(String? value) {
    if (value == null || value.isEmpty) return false;
    final emailRegExp = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
    return emailRegExp.hasMatch(value);
  }

  static bool isValidPassword(String? value) {
    if (value == null) return false;
    return value.trim().length >= 6;
  }

  static bool isRequired(String? value) {
    if (value == null) return false;
    return value.trim().isNotEmpty;
  }

  static String formatCurrency(num value) {
    return '¥${value.toStringAsFixed(2)}';
  }
}

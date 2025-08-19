class FormValidators {
  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入電子信箱';
    }
    if (!value.contains('@')) {
      return '請輸入有效的電子信箱';
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入密碼';
    }
    if (value.length < 6) {
      return '密碼至少需要6個字元';
    }
    return null;
  }

  static String? requiredValidator(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '請輸入$fieldName';
    }
    return null;
  }
}

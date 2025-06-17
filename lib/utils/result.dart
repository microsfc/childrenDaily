class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  Result._({this.data, this.error, required this.isSuccess});

  factory Result.success(T data) {
    return Result._(
      data: data,
      isSuccess: true,
    );
  }

  factory Result.error(String error) {
    return Result._(
      error: error,
      isSuccess: false,
    );
  }

  T? get value  => isSuccess ? data : null;

  void whenSuccess(Function(T) callback) {
    if (isSuccess && data != null) {
      callback(data as T);
    }
  }

  void whenFailure(Function(String) callback) {
    if (!isSuccess && error != null) {
      callback(error!);
    }
  }
}
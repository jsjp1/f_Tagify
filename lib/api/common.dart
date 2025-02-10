class ApiResponse<T> {
  final T? data;
  final String? errorMessage;
  final bool success;
  final int statusCode;

  ApiResponse(
      {this.data,
      this.errorMessage,
      required this.success,
      required this.statusCode});

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'message': errorMessage,
      'success': success,
      'statusCode': statusCode,
    };
  }
}

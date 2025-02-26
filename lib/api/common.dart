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

  factory ApiResponse.empty() {
    return ApiResponse(success: false, statusCode: 200);
  }
}

class Tag {
  final String tagName;
  final int id;

  const Tag({
    required this.tagName,
    required this.id,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json["tag_id"],
      tagName: json["tag"],
    );
  }
}

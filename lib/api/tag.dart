import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/api/dio.dart';

Future<ApiResponse<List<Tag>>> fetchUserTags(int userId) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/tags/user/$userId";

  try {
    final response = await ApiClient.dio.get(serverHost);

    if (response.statusCode == 200) {
      List<dynamic> jsonList = response.data;
      List<Tag> tags = jsonList.map((item) => Tag.fromJson(item)).toList();

      return ApiResponse(
          data: tags, statusCode: response.statusCode!, success: true);
    }
    return ApiResponse(
        errorMessage: "failure",
        statusCode: response.statusCode!,
        success: false);
  } catch (e) {
    return ApiResponse(
        errorMessage: e.toString(), statusCode: 500, success: false);
  }
}

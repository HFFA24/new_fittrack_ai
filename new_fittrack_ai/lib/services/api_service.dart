import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static Future<String> fetchUserHash(String userId) async {
    final url = Uri.parse('https://your-backend.com/get_user_hash');
    final res = await http.post(
      url,
      body: json.encode({'user_id': userId}),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      return json.decode(res.body)['user_hash'];
    } else {
      throw Exception('❌ Failed to fetch user hash');
    }
  }
}

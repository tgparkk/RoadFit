import 'package:http/http.dart' as http;
import 'dart:convert';

class KakaoGeocodingService {
  final String apiKey = '83c5d637b795bf49ea13c7f63dbfc0f0';

  Future<Map<String, String>> getCoordinates(String address) async {
    final String encodedAddress = Uri.encodeQueryComponent(address);
    final String apiUrl = 'https://dapi.kakao.com/v2/local/search/address.json?query=$encodedAddress';

    print('Request URL: $apiUrl');

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'KakaoAK $apiKey',
          'Content-Type': 'application/json',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final rawData = json.decode(response.body);

        if (rawData['documents'] != null && rawData['documents'].isNotEmpty) {
          final document = rawData['documents'][0];
          final x = document['x'] ?? '';
          final y = document['y'] ?? '';

          print('Extracted Coordinates: x=$x, y=$y');
          return {'x': x, 'y': y};
        } else {
          print('No results found in documents.');
          return {'x': '', 'y': ''};
        }
      } else {
        print('API Error: ${response.statusCode}, ${response.body}');
        return {'x': '', 'y': ''};
      }
    } catch (e) {
      print('API Call Exception: $e');
      return {'x': '', 'y': ''};
    }
  }
}

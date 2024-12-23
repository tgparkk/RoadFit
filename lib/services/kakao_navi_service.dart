import 'package:http/http.dart' as http;
import 'dart:convert';

class KakaoNaviService {
  final String apiKey = '83c5d637b795bf49ea13c7f63dbfc0f0';

  /// 출발지와 도착지 좌표를 사용해 경로 탐색
  Future<Map<String, dynamic>> getRoute(String startX, String startY, String endX, String endY) async {
    final String apiUrl =
        'https://apis-navi.kakaomobility.com/v1/directions?origin=$startX,$startY&destination=$endX,$endY';

    print('🟢 Request URL: $apiUrl');

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'KakaoAK $apiKey',
          'Content-Type': 'application/json',
        },
      );

      print('🔵 Response Status Code: ${response.statusCode}');
      print('🔵 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final rawData = json.decode(response.body);

        if (rawData['routes'] != null && rawData['routes'].isNotEmpty) {
          final route = rawData['routes'][0];
          final summary = route['summary'];
          final resultCode = route['result_code'];

          if (resultCode == 0) {
            final duration = (summary['duration'] / 60).toStringAsFixed(0); // 분 단위
            final distance = (summary['distance'] / 1000).toStringAsFixed(1); // km 단위

            print('🟡 Route Found: duration=$duration min, distance=$distance km');
            return {
              'duration': duration,
              'distance': distance,
              'fare': summary['fare'],
              'origin': summary['origin'],
              'destination': summary['destination'],
            };
          } else {
            print('❌ API Error: result_code=${route['result_code']}, message=${route['result_msg']}');
            return {};
          }
        } else {
          print('❌ API Response Error: No routes found');
          return {};
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}, ${response.body}');
        return {};
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {};
    }
  }
}

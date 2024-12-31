import 'package:http/http.dart' as http;
import 'dart:convert';

class KakaoNaviService {
  final String apiKey = '83c5d637b795bf49ea13c7f63dbfc0f0';

  /// 출발지와 도착지 좌표를 사용해 경로 탐색
  Future<Map<String, dynamic>> getRoute(String startX, String startY, String endX, String endY, String selectedPriority) async {
    final String apiUrl =
        'https://apis-navi.kakaomobility.com/v1/directions?origin=$startX,$startY&destination=$endX,$endY&priority=$selectedPriority';

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

            // 🟡 vertexes 추출 (sections → roads → vertexes)
            final vertexes = <List<double>>[];
            if (route['sections'] != null) {
              for (var section in route['sections']) {
                if (section['roads'] != null) {
                  for (var road in section['roads']) {
                    if (road['vertexes'] != null) {
                      for (int i = 0; i < road['vertexes'].length; i += 2) {
                        vertexes.add([
                          double.parse(road['vertexes'][i].toString()), // x 좌표
                          double.parse(road['vertexes'][i + 1].toString()) // y 좌표
                        ]);
                      }
                    }
                  }
                }
              }
            }

            print('🟡 Route Found: duration=$duration min, distance=$distance km');
            print('🟡 Vertexes Count: ${vertexes.length}');

            return {
              'duration': duration,
              'distance': distance,
              'fare': summary['fare'],
              'origin': summary['origin'],
              'destination': summary['destination'],
              'vertexes': vertexes, // 수정된 vertexes 반환
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

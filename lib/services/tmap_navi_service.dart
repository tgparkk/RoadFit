import 'package:http/http.dart' as http;
import 'dart:convert';

class TMapNaviService {
  final String apiKey = 'ZE5LBQ5f789FzNxTlQWm22p9Jr9g1Etd6FdGnKlo';

  /// 출발지와 도착지 좌표를 사용해 경로 탐색
  Future<Map<String, dynamic>> getRoute(
      String startX, String startY, String endX, String endY) async {
    final String apiUrl =
        'https://apis.openapi.sk.com/tmap/routes?version=1&format=json&appKey=$apiKey';

    print('🟢 TMap Request: startX=$startX, startY=$startY, endX=$endX, endY=$endY');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'startX': startX,
          'startY': startY,
          'endX': endX,
          'endY': endY,
          'reqCoordType': 'WGS84GEO',
          'resCoordType': 'WGS84GEO',
          'searchOption': '0'
        }),
      );

      print('🔵 TMap Response Status: ${response.statusCode}');
      print('🔵 TMap Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final rawData = json.decode(response.body);

        final vertexes = <List<double>>[];
        if (rawData['features'] != null) {
          for (var feature in rawData['features']) {
            if (feature['geometry']['type'] == 'LineString') {
              final coordinates = feature['geometry']['coordinates'];
              for (var coord in coordinates) {
                vertexes.add([
                  double.parse(coord[0].toString()), // 경도
                  double.parse(coord[1].toString()), // 위도
                ]);
              }
            }
          }
        }

        final summary = rawData['features'][0]['properties'];

        final duration = (summary['totalTime'] / 60).toStringAsFixed(0); // 분 단위
        final distance = (summary['totalDistance'] / 1000).toStringAsFixed(1); // km 단위

        print('🟡 Route Found: duration=$duration min, distance=$distance km');
        print('🟡 Vertexes Count: ${vertexes.length}');

        return {
          'duration': duration,
          'distance': distance,
          'vertexes': vertexes,
        };
      } else {
        print('❌ TMap Error: ${response.statusCode}, ${response.body}');
        return {};
      }
    } catch (e) {
      print('❌ TMap Exception: $e');
      return {};
    }
  }
}

import 'package:http/http.dart' as http;
import 'dart:convert';

class NaverNaviService {
  final String apiKeyId = 'ohc32m5itt';
  final String apiKey = 'RSXPwa73Q93k25z9BSLKG967HAYGw6oUzmgF0RYC';

  /// 출발지와 도착지 좌표를 사용해 경로 탐색
  Future<Map<String, dynamic>> getRoute(
      String startX, String startY, String endX, String endY) async {
    final String apiUrl =
        'https://naveropenapi.apigw.ntruss.com/map-direction-15/v1/driving?start=$startX,$startY&goal=$endX,$endY&option=trafast';

    print('🟢 Naver Request: startX=$startX, startY=$startY, endX=$endX, endY=$endY');

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'X-NCP-APIGW-API-KEY-ID': apiKeyId,
          'X-NCP-APIGW-API-KEY': apiKey,
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('🔵 Naver Response Status: ${response.statusCode}');
      print('🔵 Naver Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final rawData = json.decode(response.body);

        final vertexes = <List<double>>[];
        if (rawData['route'] != null &&
            rawData['route']['trafast'] != null &&
            rawData['route']['trafast'][0]['path'] != null) {
          final path = rawData['route']['trafast'][0]['path'];
          for (var coord in path) {
            vertexes.add([
              double.parse(coord[0].toString()), // 경도
              double.parse(coord[1].toString()), // 위도
            ]);
          }
        }

        final summary = rawData['route']['trafast'][0]['summary'];

        final duration = (summary['duration'] / 60).toStringAsFixed(0); // 분 단위
        final distance = (summary['distance'] / 1000).toStringAsFixed(1); // km 단위

        print('🟡 Route Found: duration=$duration min, distance=$distance km');
        print('🟡 Vertexes Count: ${vertexes.length}');

        // ✅ 정점 리스트 로그 출력
        for (int i = 0; i < vertexes.length; i++) {
          print('🟩 Vertex $i: [${vertexes[i][0]}, ${vertexes[i][1]}]');
        }

        return {
          'duration': duration,
          'distance': distance,
          'vertexes': vertexes,
        };
      } else {
        print('❌ Naver API Error: ${response.statusCode}, ${response.body}');
        return {};
      }
    } catch (e) {
      print('❌ Naver API Exception: $e');
      return {};
    }
  }
}

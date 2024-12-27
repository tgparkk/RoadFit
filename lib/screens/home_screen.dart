import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/kakao_geocoding_service.dart';
import '../services/kakao_navi_service.dart';
import '../services/tmap_navi_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  final KakaoGeocodingService _geocodingService = KakaoGeocodingService();
  final KakaoNaviService _kakaoNaviService = KakaoNaviService();
  final TMapNaviService _tmapNaviService = TMapNaviService();

  List<List<double>> _kakaoVertexes = [];
  List<List<double>> _tmapVertexes = [];
  bool _isLoading = false;

  /// 📍 공통 좌표 변환
  Future<Map<String, dynamic>?> _fetchCoordinates() async {
    final startAddress = '강남 삼성동 100';//_startController.text.trim();
    final endAddress = '전북 삼성동 100';//_endController.text.trim();

    if (startAddress.isEmpty || endAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('출발지와 도착지 주소를 모두 입력해주세요!')),
      );
      return null;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final startCoords = await _geocodingService.getCoordinates(startAddress);
      final endCoords = await _geocodingService.getCoordinates(endAddress);

      if (startCoords == null || endCoords == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('유효한 주소를 입력해주세요!')),
        );
        setState(() {
          _isLoading = false;
        });
        return null;
      }

      return {
        'startX': startCoords['x'].toString(),
        'startY': startCoords['y'].toString(),
        'endX': endCoords['x'].toString(),
        'endY': endCoords['y'].toString(),
      };
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
      setState(() {
        _isLoading = false;
      });
      return null;
    }
  }

  /// 🟦 카카오 & 티맵 경로 탐색
  Future<void> _fetchRoutes() async {
    final coords = await _fetchCoordinates();
    if (coords == null) return;

    List<List<double>> kakaoVertexes = [];
    List<List<double>> tmapVertexes = [];

    try {
      // 🟦 카카오 경로 탐색
      final kakaoResult = await _kakaoNaviService.getRoute(
        coords['startX']!,
        coords['startY']!,
        coords['endX']!,
        coords['endY']!,
      );

      kakaoVertexes = (kakaoResult['vertexes'] as List<dynamic>?)
          ?.map<List<double>>((vertex) => [vertex[0], vertex[1]])
          .toList() ??
          [];

      print('🟦 Kakao Vertexes loaded: ${kakaoVertexes.length}');
    } catch (e) {
      print('❌ 카카오 경로 탐색 오류: $e');
    }

    try {
      // 🟥 티맵 경로 탐색
      final tmapResult = await _tmapNaviService.getRoute(
        coords['startX']!,
        coords['startY']!,
        coords['endX']!,
        coords['endY']!,
      );

      tmapVertexes = (tmapResult['vertexes'] as List<dynamic>?)
          ?.map<List<double>>((vertex) => [vertex[0], vertex[1]])
          .toList() ??
          [];

      print('🟥 TMap Vertexes loaded: ${tmapVertexes.length}');
    } catch (e) {
      print('❌ 티맵 경로 탐색 오류: $e');
    }

    // ✅ 상태 업데이트 (항상 갱신)
    setState(() {
      _kakaoVertexes = kakaoVertexes;
      _tmapVertexes = tmapVertexes;
      _isLoading = false;
    });

    if (kakaoVertexes.isNotEmpty) {
      print('✅ Kakao 경로가 지도에 표시됩니다.');
    }
    if (tmapVertexes.isNotEmpty) {
      print('✅ TMap 경로가 지도에 표시됩니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Screen')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _startController,
                  decoration: InputDecoration(
                    labelText: '출발지 주소',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _endController,
                  decoration: InputDecoration(
                    labelText: '도착지 주소',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _fetchRoutes,
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('경로 탐색'),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: AndroidView(
              key: ValueKey(_kakaoVertexes.hashCode ^ _tmapVertexes.hashCode),
              viewType: 'kakao-map-view',
              layoutDirection: TextDirection.ltr,
              creationParams: <String, dynamic>{
                'kakaoVertexes': _kakaoVertexes,
                'tmapVertexes': _tmapVertexes,
              },
              creationParamsCodec: const StandardMessageCodec(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }
}

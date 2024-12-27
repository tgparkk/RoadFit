import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/kakao_geocoding_service.dart';
import '../services/kakao_navi_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  final KakaoGeocodingService _geocodingService = KakaoGeocodingService();
  final KakaoNaviService _naviService = KakaoNaviService();

  List<List<double>> _kakaoVertexes = [];
  bool _isLoading = false;

  /// 경로 탐색
  Future<void> _fetchRoute() async {
    final startAddress = '강남 삼성동 100';//_startController.text.trim();
    final endAddress = '전북 삼성동 100';//_endController.text.trim();

    if (startAddress.isEmpty || endAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('출발지와 도착지 주소를 모두 입력해주세요!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 주소 → 좌표 변환
      final startCoords = await _geocodingService.getCoordinates(startAddress);
      final endCoords = await _geocodingService.getCoordinates(endAddress);

      if (startCoords == null || endCoords == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('유효한 주소를 입력해주세요!')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 경로 탐색
      final result = await _naviService.getRoute(
        startCoords['x'].toString(),
        startCoords['y'].toString(),
        endCoords['x'].toString(),
        endCoords['y'].toString(),
      );

      setState(() {
        _kakaoVertexes = (result['vertexes'] as List<dynamic>?)
            ?.map<List<double>>((vertex) => [vertex[0], vertex[1]])
            .toList() ??
            [];
        _isLoading = false;
      });

      print('🟡 Vertexes loaded: $_kakaoVertexes');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
      setState(() {
        _isLoading = false;
      });
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
                  onPressed: _isLoading ? null : _fetchRoute,
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('경로 탐색'),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: _kakaoVertexes.isNotEmpty
                ? AndroidView(
              key: ValueKey(_kakaoVertexes.hashCode), // ✅ 키 추가
              viewType: 'kakao-map-view',
              layoutDirection: TextDirection.ltr,
              creationParams: <String, dynamic>{
                'vertexes': _kakaoVertexes,
              },
              creationParamsCodec: const StandardMessageCodec(),
            )
                : Center(child: Text('경로를 탐색한 후 지도를 표시합니다.')),
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

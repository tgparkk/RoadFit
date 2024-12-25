import 'package:flutter/material.dart';
import '../services/kakao_geocoding_service.dart'; // 주소 → 좌표 변환 서비스
import '../services/kakao_navi_service.dart'; // 경로 탐색 서비스

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  final KakaoGeocodingService _geocodingService = KakaoGeocodingService();
  final KakaoNaviService _naviService = KakaoNaviService();

  List<List<double>> _kakaoVertexes = []; // 정점 데이터를 저장할 리스트
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
            child: _kakaoVertexes.isEmpty
                ? Center(child: Text('경로 정점이 없습니다.'))
                : ListView.builder(
              itemCount: _kakaoVertexes.length,
              itemBuilder: (context, index) {
                final vertex = _kakaoVertexes[index];
                return ListTile(
                  title: Text('정점 $index'),
                  subtitle: Text('X: ${vertex[0]}, Y: ${vertex[1]}'),
                );
              },
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

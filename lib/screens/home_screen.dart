import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/kakao_geocoding_service.dart';
import '../services/kakao_navi_service.dart';
import '../services/tmap_navi_service.dart';
import '../services/naver_navi_service.dart';

import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';


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
  final NaverNaviService _naverNaviService = NaverNaviService();

  List<List<double>> _kakaoVertexes = [];
  List<List<double>> _tmapVertexes = [];
  List<List<double>> _naverVertexes = [];

  List<Map<String, String>> _routeInfo = [];
  bool _isLoading = false;


  /// ✅ 슬라이더 포커싱된 인덱스
  static const MethodChannel _channel = MethodChannel('kakao_map_channel');
  int _currentFocusedIndex = 0;

  /// 📊 정점 업데이트 (MethodChannel)
  Future<void> _updateVertexes() async {
    try {
      await _channel.invokeMethod('updateVertexes', {
        'kakaoVertexes': _kakaoVertexes,
        'tmapVertexes': _tmapVertexes,
        'naverVertexes': _naverVertexes,
      });
      print('✅ Vertexes updated via MethodChannel');
    } catch (e) {
      print('❌ Failed to update vertexes via MethodChannel: $e');
    }
  }

  Future<void> _updateFocusedRoute() async {
    if (_routeInfo.isNotEmpty && _currentFocusedIndex < _routeInfo.length) {
      final focusedRoute = _routeInfo[_currentFocusedIndex]['apiName'];
      try {
        await _channel.invokeMethod('updateFocusedRoute', {'focusedRoute': focusedRoute});
        print('✅ Focused Route updated via MethodChannel: $focusedRoute');
      } catch (e) {
        print('❌ Failed to update focused route via MethodChannel: $e');
      }
    } else {
      print('⚠️ No valid focused route found.');
    }
  }


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

  /// 🟦 경로 탐색
  Future<void> _fetchRoutes() async {
    final coords = await _fetchCoordinates();
    if (coords == null) return;

    List<List<double>> kakaoVertexes = [];
    List<List<double>> tmapVertexes = [];
    List<List<double>> naverVertexes = [];

    String kakaoTotalTime = '';
    String kakaoTotalDistance = '';
    String tmapTotalTime = '';
    String tmapTotalDistance = '';
    String naverTotalTime = '';
    String naverTotalDistance = '';

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
          .toList() ?? [];

      kakaoTotalTime = kakaoResult['duration'] != null
          ? '${kakaoResult['duration']}분'
          : '데이터 없음';
      kakaoTotalDistance = kakaoResult['distance'] != null
          ? '${kakaoResult['distance']}km'
          : '데이터 없음';

      print('🟦 Kakao Duration: $kakaoTotalTime');
      print('🟦 Kakao Distance: $kakaoTotalDistance');
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
          .toList() ?? [];

      tmapTotalTime = tmapResult['duration'] != null
          ? '${tmapResult['duration']}분'
          : '데이터 없음';
      tmapTotalDistance = tmapResult['distance'] != null
          ? '${tmapResult['distance']}km'
          : '데이터 없음';

      print('🟥 TMap Duration: $tmapTotalTime');
      print('🟥 TMap Distance: $tmapTotalDistance');
    } catch (e) {
      print('❌ 티맵 경로 탐색 오류: $e');
    }

    try {
      // 🟩 네이버 경로 탐색
      final naverResult = await _naverNaviService.getRoute(
        coords['startX']!,
        coords['startY']!,
        coords['endX']!,
        coords['endY']!,
      );

      naverVertexes = (naverResult['vertexes'] as List<dynamic>?)
          ?.map<List<double>>((vertex) => [vertex[0], vertex[1]])
          .toList() ?? [];

      naverTotalTime = naverResult['duration'] != null
          ? '${naverResult['duration']}분'
          : '데이터 없음';
      naverTotalDistance = naverResult['distance'] != null
          ? '${naverResult['distance']}km'
          : '데이터 없음';

      print('🟩 Naver Duration: $naverTotalTime');
      print('🟩 Naver Distance: $naverTotalDistance');
    } catch (e) {
      print('❌ Naver API Error: $e');
    }

    // ✅ 상태 업데이트
    setState(() {
      _kakaoVertexes = kakaoVertexes;
      _tmapVertexes = tmapVertexes;
      _naverVertexes = naverVertexes;

      _routeInfo = [
        {
          'apiName': 'Kakao',
          'totalTime': kakaoTotalTime,
          'totalDistance': kakaoTotalDistance,
        },
        {
          'apiName': 'Naver',
          'totalTime': naverTotalTime,
          'totalDistance': naverTotalDistance,
        },
        {
          'apiName': 'TMap',
          'totalTime': tmapTotalTime,
          'totalDistance': tmapTotalDistance,
        },
      ];
      _isLoading = false;
    });
    // 🟢 Vertex 업데이트
    await _updateVertexes();

  }

  /// ✅ 카카오내비 실행 함수
  Future<void> _launchKakaoNavi() async {
    try {

      // 카카오내비 앱 설치 여부 확인
      if (await NaviApi.instance.isKakaoNaviInstalled()) {
        // ✅ 카카오내비 앱 실행
        final uri = NaviApi.instance.navigate(
          destination: Location(
              name: '카카오 판교오피스',
              x: '127.108640',
              y: '37.402111'
          ),
          option: NaviOption(coordType: CoordType.wgs84),
        );

      } else {
        // 카카오내비 설치 페이지로 이동
        /*
        startActivity(
            Intent(
                Intent.ACTION_VIEW,
                Uri.parse(Constants.WEB_NAVI_INSTALL)
            ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        )
        */
      }
    } catch (e) {
      print('❌ 카카오내비 실행 오류: $e');
    }
  }

  /// ✅ 알림창 표시 함수
  Future<void> _showNaviDialog(String apiName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // 외부 터치로 닫기
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$apiName 내비게이션 실행'),
          content: Text('$apiName 내비 앱을 실행하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                if (apiName == 'Kakao') {
                  _launchKakaoNavi(); // 카카오 내비 실행
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// ✅ 슬라이더 카드 터치 이벤트
  void _onSliderTouched(String apiName) {
    if (apiName == 'Kakao') {
      _showNaviDialog(apiName);
    } else {
      print('❌ $apiName 내비게이션 실행은 아직 구현되지 않았습니다.');
    }
  }

  /// ✅ 경로 카드 UI
  Widget _buildRouteCard(String apiName, String totalTime, String totalDistance) {
    return GestureDetector(
      onTap: () => _onSliderTouched(apiName), // 터치 이벤트
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          title: Text('$apiName 경로 정보'),
          subtitle: Text('예상 시간: $totalTime | 거리: $totalDistance'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    print('🟦 Kakao Vertexes: $_kakaoVertexes');
    print('🟥 TMap Vertexes: $_tmapVertexes');
    print('🟩 Naver Vertexes: $_naverVertexes');
    print('🎯 Focused Route: ${_routeInfo.isNotEmpty && _currentFocusedIndex < _routeInfo.length ? _routeInfo[_currentFocusedIndex]['apiName'] : "null"}');


    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Road Fit', style: TextStyle(fontSize: 20)),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _fetchRoutes,
              icon: Icon(Icons.route),
              label: _isLoading
                  ? SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('경로 탐색'),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 🗺️ 지도 영역
          Positioned.fill(
            child: AndroidView(
              //key: ValueKey(_kakaoVertexes.hashCode ^ _tmapVertexes.hashCode ^ _naverVertexes.hashCode),
              key: ValueKey('kakao-map-view'), // 고정된 key 사용
              viewType: 'kakao-map-view',
              layoutDirection: TextDirection.ltr,
              creationParams: {
                'kakaoVertexes': _kakaoVertexes,
                'tmapVertexes': _tmapVertexes,
                'naverVertexes': _naverVertexes,
                'focusedRoute': _routeInfo.isNotEmpty && _currentFocusedIndex < _routeInfo.length
                    ? _routeInfo[_currentFocusedIndex]['apiName']
                    : null,
              },
              creationParamsCodec: const StandardMessageCodec(),
            )
          ),
          // 📍 주소 입력 필드
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(controller: _startController, decoration: InputDecoration(labelText: '출발지 주소')),
                  SizedBox(height: 8),
                  TextField(controller: _endController, decoration: InputDecoration(labelText: '도착지 주소')),
                ],
              ),
            ),
          ),
          // 📊 슬라이더
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 200,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.85),
                itemCount: _routeInfo.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentFocusedIndex = index;
                  });
                  _updateFocusedRoute(); // MethodChannel 호출
                },
                itemBuilder: (context, index) {
                  final info = _routeInfo[index];
                  return _buildRouteCard(
                    info['apiName']!,
                    info['totalTime']!,
                    info['totalDistance']!,
                  );
                },
              ),
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

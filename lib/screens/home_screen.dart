import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/kakao_geocoding_service.dart';
import '../services/kakao_navi_service.dart';
import '../services/tmap_navi_service.dart';
import '../services/naver_navi_service.dart';

import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/KakaoSliderWidget.dart';


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

  late String _startAddress;
  late String _endAddress;

  late String _startX;
  late String _startY;
  late String _endX;
  late String _endY;

  // Kakao Priority Selection State
  String _kakaoSelectedPriority = 'RECOMMEND';

  /// ✅ 슬라이더 포커싱된 인덱스
  static const MethodChannel _channel = MethodChannel('kakao_map_channel');
  int _currentFocusedIndex = 0;

  GlobalKey<KakaoSliderWidgetState> _sliderKey = GlobalKey<KakaoSliderWidgetState>();



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
    _startAddress = '강남 삼성동 100';//_startController.text.trim();
    _endAddress = '전북 삼성동 100';//_endController.text.trim();

    if (_startAddress.isEmpty || _endAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('출발지와 도착지 주소를 모두 입력해주세요!')),
      );
      return null;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final startCoords = await _geocodingService.getCoordinates(_startAddress);
      final endCoords = await _geocodingService.getCoordinates(_endAddress);

      if (startCoords == null || endCoords == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('유효한 주소를 입력해주세요!')),
        );
        setState(() {
          _isLoading = false;
        });
        return null;
      }

      _startX = startCoords['x'].toString();
      _startY = startCoords['y'].toString();
      _endX = endCoords['x'].toString();
      _endY = endCoords['y'].toString();

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

  /// ✅ Fetch Kakao Route
  Future<Map<String, dynamic>> _fetchKakaoRoute(Map<String, dynamic> coords) async {
    List<List<double>> kakaoVertexes = [];
    String kakaoTotalTime = '';
    String kakaoTotalDistance = '';

    try {
      final kakaoResult = await _kakaoNaviService.getRoute(
        _startX,
        _startY,
        _endX,
        _endY,
        _kakaoSelectedPriority,
      );

      kakaoVertexes = (kakaoResult['vertexes'] as List<dynamic>?)
          ?.map<List<double>>((vertex) => [vertex[0], vertex[1]])
          .toList() ?? [];

      kakaoTotalTime = kakaoResult['duration'] != null
          ? '${kakaoResult['duration']} minutes'
          : 'No data';
      kakaoTotalDistance = kakaoResult['distance'] != null
          ? '${kakaoResult['distance']}km'
          : 'No data';

      print('🟦 Kakao Duration: $kakaoTotalTime');
      print('🟦 Kakao Distance: $kakaoTotalDistance');
    } catch (e) {
      print('❌ Kakao Route Search Error: $e');
    }

    return {
      'vertexes': kakaoVertexes,
      'totalTime': kakaoTotalTime,
      'totalDistance': kakaoTotalDistance,
    };
  }

  /// ✅ Update Kakao Route and Redraw Slider
  Future<void> _updateKakaoRoute() async {
    try {
      print('🚀 Fetching Kakao Route Info with priority: $_kakaoSelectedPriority');

      final kakaoResult = await _kakaoNaviService.getRoute(
        _startX,
        _startY,
        _endX,
        _endY,
        _kakaoSelectedPriority,
      );

      // Log the full API response
      print('🔍 Kakao API Response: $kakaoResult');

      setState(() {
        _kakaoVertexes = kakaoResult['vertexes'] as List<List<double>>? ?? [];

        _routeInfo[0] = {
          'apiName': 'Kakao',
          'totalTime': kakaoResult['duration'] != null
              ? kakaoResult['duration'].toString()
              : 'No data',
          'totalDistance': kakaoResult['distance'] != null
              ? kakaoResult['distance'].toString()
              : 'No data',
        };

        print('🔄 Final Updated routeInfo: $_routeInfo');

        // Force Widget Recreation
        _sliderKey = GlobalKey<KakaoSliderWidgetState>();
      });


      print('✅ Kakao Route Info Updated Successfully');
      print('🔄 Updated routeInfo: $_routeInfo');

      // ✅ Force Slider Widget Rebuild
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_sliderKey.currentState != null) {
          print('🔄 Manually Triggering Slider Rebuild');
          _sliderKey.currentState!.rebuild();
        } else {
          print('❌ Slider Key State is null!');
        }
      });

      // ✅ Trigger Vertex Update After Fetching Route Data
      await _updateVertexes();

      print('✅ Kakao Route Info Updated Successfully');
    } catch (e) {
      print('❌ Failed to fetch Kakao Route Info: $e');
    }
  }



  /// ✅ Fetch Tmap Route
  Future<Map<String, dynamic>> _fetchTmapRoute(Map<String, dynamic> coords) async {
    List<List<double>> tmapVertexes = [];
    String tmapTotalTime = '';
    String tmapTotalDistance = '';

    try {
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
          ? '${tmapResult['duration']} minutes'
          : 'No data';
      tmapTotalDistance = tmapResult['distance'] != null
          ? '${tmapResult['distance']}km'
          : 'No data';

      print('🟥 Tmap Duration: $tmapTotalTime');
      print('🟥 Tmap Distance: $tmapTotalDistance');
    } catch (e) {
      print('❌ Tmap Route Search Error: $e');
    }

    return {
      'vertexes': tmapVertexes,
      'totalTime': tmapTotalTime,
      'totalDistance': tmapTotalDistance,
    };
  }

  /// ✅ Fetch Naver Route
  Future<Map<String, dynamic>> _fetchNaverRoute(Map<String, dynamic> coords) async {
    List<List<double>> naverVertexes = [];
    String naverTotalTime = '';
    String naverTotalDistance = '';

    try {
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
          ? '${naverResult['duration']} minutes'
          : 'No data';
      naverTotalDistance = naverResult['distance'] != null
          ? '${naverResult['distance']}km'
          : 'No data';

      print('🟩 Naver Duration: $naverTotalTime');
      print('🟩 Naver Distance: $naverTotalDistance');
    } catch (e) {
      print('❌ Naver API Error: $e');
    }

    return {
      'vertexes': naverVertexes,
      'totalTime': naverTotalTime,
      'totalDistance': naverTotalDistance,
    };
  }

  /// ✅ Main Route Fetch Function
  Future<void> _fetchRoutes() async {
    final coords = await _fetchCoordinates();

    // 🛡️ Null check for coordinates
    if (coords == null) {
      print('❌ Coordinates could not be fetched.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 🟢 Fetch routes concurrently
      final results = await Future.wait<Map<String, dynamic>>([
        _fetchKakaoRoute(coords),
        _fetchTmapRoute(coords),
        _fetchNaverRoute(coords),
      ]);


      final kakaoData = results[0];
      final tmapData = results[1];
      final naverData = results[2];

      setState(() {
        _kakaoVertexes = kakaoData['vertexes'];
        _tmapVertexes = tmapData['vertexes'];
        _naverVertexes = naverData['vertexes'];

        _routeInfo = [
          {
            'apiName': 'Kakao',
            'totalTime': kakaoData['totalTime'],
            'totalDistance': kakaoData['totalDistance'],
          },
          {
            'apiName': 'Tmap',
            'totalTime': tmapData['totalTime'],
            'totalDistance': tmapData['totalDistance'],
          },
          {
            'apiName': 'Naver',
            'totalTime': naverData['totalTime'],
            'totalDistance': naverData['totalDistance'],
          },
        ];

        _isLoading = false;
      });

      // 🟢 Update Vertices
      await _updateVertexes();

      print('✅ All routes fetched and updated.');
    } catch (e) {
      print('❌ Failed to fetch routes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// ✅ Kakao Navi Launch Function with Enhanced Logs
  Future<void> _launchKakaoNavi(String endX, String endY, String endAddress) async {
    print('🔄 Attempting to launch Kakao Navi...');
    print('📝 Parameters:');
    print('   📍 Destination Name: $endAddress');
    print('   📍 Longitude (endX): $endX');
    print('   📍 Latitude (endY): $endY');

    try {

      // Step 2: Check if Kakao Navi is installed
      final isInstalled = await NaviApi.instance.isKakaoNaviInstalled();
      print(isInstalled
          ? '✅ Kakao Navi is installed.'
          : '⚠️ Kakao Navi is not installed. Redirecting to installation page...');



      if (isInstalled) {
        // Step 3: Generate URI for Kakao Navi Navigation
        print('🔗 Generating Kakao Navi URI...');
        final Uri uri = await NaviApi.instance.navigate(
          destination: Location(
            name: endAddress,
            x: endX,
            y: endY,
          ),
          option: NaviOption(coordType: CoordType.wgs84, rpOption: RpOption.fast)
        );

        print('✅ URI Generated: $uri');

        // Step 4: Launch Kakao Navi app
        final canLaunch = await canLaunchUrl(uri);
        print(canLaunch
            ? '✅ URI is valid and can be launched.'
            : '❌ URI cannot be launched. Check the URI syntax.');

        if (canLaunch) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          print('✅ Kakao Navi launched successfully!');
        } else {
          print('❌ Failed to launch Kakao Navi URI: $uri');
        }
      } else {
        // Step 5: Redirect to Kakao Navi installation page
        final Uri webUri = Uri.parse('https://kakaonavi.kakao.com/launch/index.do');
        print('🔗 Redirecting to Kakao Navi installation page: $webUri');

        if (await canLaunchUrl(webUri)) {
          await launchUrl(
            webUri,
            mode: LaunchMode.externalApplication,
          );
          print('✅ Redirected to Kakao Navi installation page.');
        } else {
          print('❌ Failed to redirect to Kakao Navi installation page: $webUri');
        }
      }
    } catch (e) {
      print('❌ Kakao Navi launch error: $e');
    }
  }

  /// ✅ 알림창 표시 함수
  Future<void> _showKaKaoNaviDialog(String apiName) async {
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
                  _launchKakaoNavi(_endX, _endY, _endAddress); // 카카오 내비 실행
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
      _showKaKaoNaviDialog(apiName);
    } else {
      print('❌ $apiName 내비게이션 실행은 아직 구현되지 않았습니다.');
    }
  }

  /// ✅ Kakao Slider Card with Height Adjustments
  Widget _buildKakaoRouteCard(String apiName, String totalTime, String totalDistance) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          /// 🔵 Upper Touch Area (Reduced Height)
          GestureDetector(
            onTap: () => _onSliderTouched(apiName),
            child: Container(
              height: 70, // Reduced height
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.map, color: Colors.blueAccent, size: 28),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$apiName 경로 정보',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '예상 시간: $totalTime | 거리: $totalDistance',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Divider(height: 1),

          /// 🔵 Lower Checkbox Area (Increased Height)
          Container(
            height: 130, // Increased height
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📍 Select Route Priority',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPriorityCheckbox('RECOMMEND', Icons.star, Colors.green),
                    _buildPriorityCheckbox('TIME', Icons.timer, Colors.blue),
                    _buildPriorityCheckbox('DISTANCE', Icons.route, Colors.red),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1),

          /// ✅ Kakao Slider Widget (Placed Here)
          KakaoSliderWidget(
            key: ValueKey(_routeInfo[0]['totalTime']),
            routeInfo: _routeInfo,
          ),
        ],
      ),
    );
  }


  /// ✅ Build Checkbox Item
  Widget _buildPriorityCheckbox(String priority, IconData icon, Color color) {
    bool isSelected = _kakaoSelectedPriority == priority;
    return GestureDetector(
      onTap: () async {
        if (_kakaoSelectedPriority != priority) {
          setState(() {
            _kakaoSelectedPriority = priority;
          });
          print('📝 Selected Kakao Priority: $_kakaoSelectedPriority');
          await _updateKakaoRoute();
        }
      },
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? color : Colors.grey,
            size: 28,
          ),
          SizedBox(height: 4),
          Text(
            priority,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : Colors.grey,
            ),
          ),
          Checkbox(
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                _kakaoSelectedPriority = priority;
              });
              print('📝 Checkbox Selected Priority: $_kakaoSelectedPriority');
            },
            activeColor: color,
          ),
        ],
      ),
    );
  }

  /// ✅ Build Default Route Card for Naver and Tmap
  Widget _buildDefaultRouteCard(String apiName, String totalTime, String totalDistance) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(Icons.directions, color: Colors.blue),
        title: Text('$apiName 경로 정보'),
        subtitle: Text('예상 시간: $totalTime | 거리: $totalDistance'),
      ),
    );
  }

  /// ✅ Build Route Card Based on API Name
  Widget _buildRouteCard(String apiName, String totalTime, String totalDistance) {
    if (apiName == 'Kakao') {
      return _buildKakaoRouteCard(apiName, totalTime, totalDistance);
    } else {
      return _buildDefaultRouteCard(apiName, totalTime, totalDistance);
    }
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
                  SizedBox(height: 12),
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

import 'package:flutter/material.dart';
import '../services/kakao_geocoding_service.dart';
import '../services/kakao_navi_service.dart';
import '../widgets/map_view.dart';
import '../widgets/route_slider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  bool _isRouteFetched = false;
  String _selectedRoute = '카카오 경로';

  List<Map<String, String>> _routeInfo = [];
  final KakaoGeocodingService _geocodingService = KakaoGeocodingService();
  final KakaoNaviService _naviService = KakaoNaviService();

  /// 경로 탐색 실행
  Future<void> _fetchRoutes() async {
    String departure = _departureController.text;
    String destination = _destinationController.text;

    if (departure.isEmpty || destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('출발지와 도착지를 입력하세요!')),
      );
      return;
    }

    setState(() {
      _isRouteFetched = false;
    });

    try {
      final departureCoordinates = await _geocodingService.getCoordinates(departure);
      final destinationCoordinates = await _geocodingService.getCoordinates(destination);

      if (departureCoordinates['x']!.isEmpty || destinationCoordinates['x']!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('출발지 또는 도착지 주소가 잘못되었습니다.')),
        );
        return;
      }

      final kakaoData = await _naviService.getRoute(
        departureCoordinates['x']!,
        departureCoordinates['y']!,
        destinationCoordinates['x']!,
        destinationCoordinates['y']!,
      );

      if (kakaoData.isNotEmpty) {
        setState(() {
          _routeInfo = [
            {'apiName': '카카오', 'duration': '${kakaoData['duration']}분', 'distance': '${kakaoData['distance']}km'},
          ];
          _isRouteFetched = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('경로를 찾을 수 없습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      print('❌ Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('경로 비교 앱')),
      body: Column(
        children: [
          TextField(controller: _departureController, decoration: InputDecoration(labelText: '출발지')),
          TextField(controller: _destinationController, decoration: InputDecoration(labelText: '도착지')),
          ElevatedButton(onPressed: _fetchRoutes, child: Text('경로 비교')),
          if (_isRouteFetched) RouteSlider(routeInfo: _routeInfo),
        ],
      ),
    );
  }
}

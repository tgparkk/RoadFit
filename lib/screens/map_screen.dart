import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapScreen extends StatefulWidget {
  final List<List<double>> routeVertexes; // API로 받은 vertex 좌표 리스트
  const MapScreen({Key? key, required this.routeVertexes}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  Set<Polyline> polylines = {}; // 경로를 그리기 위한 Polyline

  @override
  void initState() {
    super.initState();
    _setPolylines();
  }

  /// Polyline 설정
  void _setPolylines() {
    List<LatLng> polylineCoordinates = widget.routeVertexes
        .map((vertex) => LatLng(vertex[1], vertex[0])) // x, y -> LatLng(y, x)
        .toList();

    setState(() {
      polylines.add(Polyline(
        polylineId: PolylineId('kakao_route'),
        color: Colors.blue,
        width: 5,
        points: polylineCoordinates,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('경로 지도')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.routeVertexes[0][1], widget.routeVertexes[0][0]), // 출발지
          zoom: 14,
        ),
        polylines: polylines,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MapView extends StatelessWidget {
  final String selectedRoute; // 선택된 경로 정보

  MapView({required this.selectedRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: Center(
        child: Text(
          '지도 표시 영역\n선택된 경로: $selectedRoute',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

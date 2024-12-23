import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> kakaoResult;
  final Map<String, dynamic> naverResult;
  final Map<String, dynamic> tmapResult;

  ResultScreen({
    required this.kakaoResult,
    required this.naverResult,
    required this.tmapResult,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('경로 비교 결과')),
      body: ListView(
        children: [
          _buildResultCard('카카오내비', kakaoResult),
          _buildResultCard('네이버지도', naverResult),
          _buildResultCard('티맵', tmapResult),
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, Map<String, dynamic> data) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text('예상 시간: ${data['duration']}분\n거리: ${data['distance']}km'),
        trailing: ElevatedButton(
          onPressed: () {
            // 내비게이션 앱 실행 (Intent/URL Scheme)
          },
          child: Text('앱 실행'),
        ),
      ),
    );
  }
}

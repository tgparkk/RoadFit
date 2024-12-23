import 'package:flutter/material.dart';

class RouteSlider extends StatelessWidget {
  final List<Map<String, String>> routeInfo;

  RouteSlider({required this.routeInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: PageView.builder(
        itemCount: routeInfo.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('${routeInfo[index]['apiName']} 경로 정보'),
              subtitle: Text(
                '예상 시간: ${routeInfo[index]['duration']}\n거리: ${routeInfo[index]['distance']}',
              ),
            ),
          );
        },
      ),
    );
  }
}

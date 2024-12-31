import 'package:flutter/material.dart';

/// ✅ Kakao Slider Stateful Widget
class KakaoSliderWidget extends StatefulWidget {
  final List<Map<String, String>> routeInfo;

  KakaoSliderWidget({Key? key, required this.routeInfo}) : super(key: key);

  @override
  KakaoSliderWidgetState createState() => KakaoSliderWidgetState();
}

class KakaoSliderWidgetState extends State<KakaoSliderWidget> {
  @override
  Widget build(BuildContext context) {
    print('🔄 Rebuilding Slider with Updated routeInfo: ${widget.routeInfo}');
    return Container(
      height: 200,
      child: PageView.builder(
        itemCount: widget.routeInfo.length,
        itemBuilder: (context, index) {
          final info = widget.routeInfo[index];
          print('📝 Slider Displaying: ${info['apiName']}, ${info['totalTime']}, ${info['totalDistance']}');
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('${info['apiName']} 경로 정보'),
              subtitle: Text(
                '예상 시간: ${info['totalTime']}\n거리: ${info['totalDistance']}',
              ),
            ),
          );
        },
      ),
    );
  }

  /// ✅ Manually Trigger Rebuild
  void rebuild() {
    setState(() {
      print('🔄 Manually Triggering Slider Rebuild');
    });
  }
}

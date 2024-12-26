import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KakaoMapWidget extends StatelessWidget {
  const KakaoMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400, // 지도 영역 높이 (빨간 영역에 맞춤)
      child: AndroidView(
        viewType: 'kakao-map-view',
        layoutDirection: TextDirection.ltr,
        creationParams: <String, dynamic>{
          'param1': 'value1',
        },
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }
}

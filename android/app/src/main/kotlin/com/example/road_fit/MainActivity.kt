package com.example.road_fit

import android.os.Bundle
import com.kakao.vectormap.KakaoMapSdk
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.example.road_fit.KakaoMapViewFactory
import android.util.Log

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
/*
        try {
            // KakaoMap SDK 초기화
            KakaoMapSdk.init(this, "Pz8/Xz8wPz9MPz8K")
            Log.d("KakaoMapSdk", "✅ KakaoMapSdk.init 성공")
        } catch (e: Exception) {
            Log.e("KakaoMapSdk", "❌ KakaoMapSdk.init 실패: ${e.message}")
        }

 */
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "kakao-map-view", KakaoMapViewFactory()
        )
    }
}

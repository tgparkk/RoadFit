package com.example.road_fit

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.example.road_fit.KakaoMapViewFactory
import com.kakao.vectormap.KakaoMapSdk
import android.util.Log

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d("MainActivity", "✅ FlutterEngine Initialized")

        flutterEngine.platformViewsController.registry.registerViewFactory(
            "kakao-map-view", KakaoMapViewFactory()
        )
        Log.d("MainActivity", "✅ KakaoMapViewFactory Registered")
    }
}

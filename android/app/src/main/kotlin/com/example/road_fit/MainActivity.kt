package com.example.road_fit

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.example.road_fit.KakaoMapViewFactory
import com.kakao.vectormap.KakaoMapSdk
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "kakao_map_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d("MainActivity", "✅ FlutterEngine Initialized")

        flutterEngine.platformViewsController.registry.registerViewFactory(
            "kakao-map-view", KakaoMapViewFactory()
        )
        Log.d("MainActivity", "✅ KakaoMapViewFactory Registered")

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "kakao_map_channel")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "updateVertexes" -> {
                        val kakao = call.argument<List<*>>("kakaoVertexes")
                        val tmap = call.argument<List<*>>("tmapVertexes")
                        val naver = call.argument<List<*>>("naverVertexes")

                        if (kakao != null && tmap != null && naver != null) {
                            KakaoMapView.updateVertexes(kakao, tmap, naver)
                            result.success("Vertexes updated successfully")
                        } else {
                            result.error("INVALID_ARGUMENT", "One or more vertex lists are null", null)
                        }
                    }
                    "updateFocusedRoute" -> {
                        val focusedRoute = call.argument<String>("focusedRoute")
                        if (focusedRoute != null) {
                            KakaoMapView.redrawFocusedRoute(focusedRoute)
                            result.success("Focused route updated successfully")
                        } else {
                            result.error("INVALID_ARGUMENT", "Focused route is null", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }


    }
}

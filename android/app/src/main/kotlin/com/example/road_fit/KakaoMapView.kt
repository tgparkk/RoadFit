package com.example.road_fit

import android.content.Context
import android.util.Log
import android.view.View
import com.kakao.vectormap.KakaoMap
import com.kakao.vectormap.KakaoMapReadyCallback
import com.kakao.vectormap.MapLifeCycleCallback
import com.kakao.vectormap.MapView
import io.flutter.plugin.platform.PlatformView

class KakaoMapView(context: Context, args: Any?) : PlatformView {
    private val mapView: MapView = MapView(context)
    private var kakaoMap: KakaoMap? = null // 🔄 var로 변경

    init {
        // Flutter에서 전달된 매개변수 확인
        if (args is Map<*, *>) {
            println("Arguments from Flutter: $args")
        }

        // Kakao Map 초기화
        initializeMap()
    }

    private fun initializeMap() {
        mapView.start(
            object : MapLifeCycleCallback() {
                override fun onMapDestroy() {
                    Log.d("KakaoMapView", "💥 Map Destroyed")
                }

                override fun onMapError(error: Exception?) {
                    Log.e("KakaoMapView", "❌ Map Error: ${error?.message}")
                }
            },
            object : KakaoMapReadyCallback() {
                override fun onMapReady(map: KakaoMap) {
                    Log.d("KakaoMapView", "🗺️ Kakao Map is Ready")
                    kakaoMap = map // 🔄 var로 선언했기 때문에 재할당 가능
                    setupMap(map)
                }
            }
        )
    }

    private fun setupMap(kakaoMap: KakaoMap) {
        Log.d("KakaoMapView", "📍 Map Initialization Complete")
        // KakaoMap 객체를 사용해 추가적인 설정을 진행
    }

    override fun getView(): View {
        return mapView
    }

    override fun dispose() {
        mapView.finish()
        Log.d("KakaoMapView", "✅ MapView Finished")
    }
}

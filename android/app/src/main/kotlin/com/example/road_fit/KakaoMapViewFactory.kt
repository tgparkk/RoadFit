package com.example.road_fit

import android.content.Context
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec
import android.util.Log

class KakaoMapViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        if (args is Map<*, *>) {
            val kakaoVertexes = args["kakaoVertexes"] as? List<*>
            val tmapVertexes = args["tmapVertexes"] as? List<*>
            val naverVertexes = args["naverVertexes"] as? List<*>
            val focusedRoute = args["focusedRoute"] as? String

            Log.d("KakaoMapViewFactory", "🟦 Kakao Vertexes Exist: ${kakaoVertexes != null && kakaoVertexes.isNotEmpty()}")
            Log.d("KakaoMapViewFactory", "🟥 TMap Vertexes Exist: ${tmapVertexes != null && tmapVertexes.isNotEmpty()}")
            Log.d("KakaoMapViewFactory", "🟩 Naver Vertexes Exist: ${naverVertexes != null && naverVertexes.isNotEmpty()}")
            Log.d("KakaoMapViewFactory", "🎯 Focused Route: $focusedRoute")

            return KakaoMapView(context, args)
        } else {
            Log.e("KakaoMapViewFactory", "❌ Invalid arguments passed")
            return KakaoMapView(context, null)
        }
    }

}

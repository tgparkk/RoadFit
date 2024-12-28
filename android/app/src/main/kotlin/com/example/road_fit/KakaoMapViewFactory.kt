package com.example.road_fit

import android.content.Context
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec
import android.util.Log

class KakaoMapViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        Log.d("KakaoMapViewFactory", "✅ KakaoMapViewFactory.create called")
        Log.d("KakaoMapViewFactory", "✅ args: $args")
        Log.d("KakaoMapViewFactory", "✅ args type: ${args?.javaClass?.name}")

        if (args is Map<*, *>) {
            Log.d("KakaoMapViewFactory", "🟦 Kakao Vertexes: ${args["kakaoVertexes"]}")
            Log.d("KakaoMapViewFactory", "🟥 TMap Vertexes: ${args["tmapVertexes"]}")
            Log.d("KakaoMapViewFactory", "🟩 Naver Vertexes: ${args["naverVertexes"]}")

            if (!args.containsKey("naverVertexes")) {
                Log.e("KakaoMapViewFactory", "❌ 'naverVertexes' key is missing in args!")
            }
        } else {
            Log.e("KakaoMapViewFactory", "❌ args is not a Map, actual type: ${args?.javaClass?.name}")
        }

        return KakaoMapView(context, args)
    }
}

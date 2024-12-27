package com.example.road_fit

import android.content.Context
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec
import android.util.Log

class KakaoMapViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        Log.d("KakaoMapViewFactory", "✅ KakaoMapViewFactory.create called")
        return KakaoMapView(context, args)
    }
}

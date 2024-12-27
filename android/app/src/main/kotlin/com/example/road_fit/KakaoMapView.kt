package com.example.road_fit

import android.content.Context
import android.graphics.Color
import android.util.Log
import android.view.View
import com.kakao.vectormap.*
import com.kakao.vectormap.route.*
import io.flutter.plugin.platform.PlatformView

class KakaoMapView(context: Context, args: Any?) : PlatformView {
    private val mapView: MapView = MapView(context)
    private var kakaoMap: KakaoMap? = null
    private var routeLineLayer: RouteLineLayer? = null

    init {
        if (args is Map<*, *>) {
            println("Arguments from Flutter: $args")
        }
        initializeMap(args)
    }

    private fun initializeMap(args: Any?) {
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
                    kakaoMap = map
                    routeLineLayer = kakaoMap?.getRouteLineManager()?.getLayer()
                    if (routeLineLayer == null) {
                        Log.e("KakaoMapView", "❌ RouteLineLayer is null")
                        return
                    }
                    setupMap(map, args)
                }
            }
        )
    }

    private fun setupMap(map: KakaoMap, args: Any?) {
        Log.d("KakaoMapView", "📍 Map Initialization Complete")

        if (args is Map<*, *>) {
            val vertexes = args["vertexes"] as? List<*>
            if (vertexes != null) {
                drawRouteLine(vertexes)
            }
        }
    }

    private fun drawRouteLine(vertexes: List<*>) {
        try {
            if (routeLineLayer == null) {
                Log.e("KakaoMapView", "❌ RouteLineLayer is null")
                return
            }

            val stylesSet = RouteLineStylesSet.from(
                RouteLineStyles.from(RouteLineStyle.from(10f, Color.BLUE))
            )

            val segment = RouteLineSegment.from(
                vertexes.mapNotNull { vertex ->
                    if (vertex is List<*> && vertex.size == 2) {
                        val x = (vertex[0] as Number).toDouble()
                        val y = (vertex[1] as Number).toDouble()
                        LatLng.from(y, x)
                    } else null
                }
            ).setStyles(stylesSet.getStyles(0))

            val options = RouteLineOptions.from(listOf(segment))
                .setStylesSet(stylesSet)

            routeLineLayer?.addRouteLine(options)
            Log.d("KakaoMapView", "🛣️ RouteLine added successfully")

        } catch (e: Exception) {
            Log.e("KakaoMapView", "❌ Error drawing RouteLine: ${e.message}")
        }
    }

    override fun getView(): View {
        return mapView
    }

    override fun dispose() {
        mapView.finish()
        Log.d("KakaoMapView", "✅ MapView Finished")
    }
}

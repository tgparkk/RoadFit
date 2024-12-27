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

        if (args == null) {
            Log.e("KakaoMapView", "❌ args is null")
            return
        }

        // args 타입과 내용 강제 출력
        Log.d("KakaoMapView", "🛠️ args runtime type: ${args::class.java.name}")
        Log.d("KakaoMapView", "🛠️ args toString: $args")
/*
        try {
            val jsonString = args.toString()
            Log.d("KakaoMapView", "🛠️ args as String: $jsonString")
        } catch (e: Exception) {
            Log.e("KakaoMapView", "❌ Exception while printing args: ${e.message}")
        }
*/
        if (args is Map<*, *>) {
            Log.d("KakaoMapView", "✅ args is Map")

            val kakaoVertexes = args["kakaoVertexes"] as? List<*>
            Log.d("KakaoMapView", "🟦 Kakao Vertexes: $kakaoVertexes")
            if (kakaoVertexes != null && kakaoVertexes.isNotEmpty()) {
                drawRouteLine(kakaoVertexes, "KAKAO")
            } else {
                Log.w("KakaoMapView", "⚠️ Kakao Vertexes are null or empty")
            }

            val tmapVertexes = args["tmapVertexes"] as? List<*>
            Log.d("KakaoMapView", "🟥 TMap Vertexes: $tmapVertexes")
            if (tmapVertexes != null && tmapVertexes.isNotEmpty()) {
                drawRouteLine(tmapVertexes, "TMAP")
            } else {
                Log.w("KakaoMapView", "⚠️ TMap Vertexes are null or empty")
            }
        } else {
            Log.e("KakaoMapView", "❌ args is not a Map, actual type: ${args::class.java.name}")
        }
    }





    private fun drawRouteLine(vertexes: List<*>, source: String) {
        try {
            if (routeLineLayer == null) {
                Log.e("KakaoMapView", "❌ RouteLineLayer is null")
                return
            }

            Log.d("KakaoMapView", "📍 RouteLineLayer is not null")

            val stylesSet = RouteLineStylesSet.from(
                RouteLineStyles.from(
                    when (source) {
                        "KAKAO" -> RouteLineStyle.from(10f, Color.BLUE)
                        "TMAP" -> RouteLineStyle.from(10f, Color.RED)
                        else -> RouteLineStyle.from(10f, Color.GRAY)
                    }
                )
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
            Log.d("KakaoMapView", "🛣️ RouteLine added for $source")

        } catch (e: Exception) {
            Log.e("KakaoMapView", "❌ Error drawing RouteLine for $source: ${e.message}")
        }
    }

    override fun getView(): View {
        Log.d("KakaoMapView", "🟢 getView() called")
        return mapView
    }

    override fun dispose() {
        mapView.finish()
        Log.d("KakaoMapView", "✅ MapView Finished")
    }

}
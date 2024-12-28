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

        Log.d("KakaoMapView", "🛠️ args runtime type: ${args::class.java.name}")
        Log.d("KakaoMapView", "🛠️ args content: $args")

        if (args is Map<*, *>) {
            Log.d("KakaoMapView", "✅ args is Map")

            // 🔍 Kakao Vertexes 확인
            val kakaoVertexes = args["kakaoVertexes"]
            Log.d("KakaoMapView", "🟦 Kakao Vertexes (Raw): $kakaoVertexes")
            if (kakaoVertexes is List<*>) {
                Log.d("KakaoMapView", "🟦 Kakao Vertexes Size: ${kakaoVertexes.size}")
                if (kakaoVertexes.isNotEmpty()) {
                    Log.d("KakaoMapView", "🟦 Kakao Vertexes are valid")
                    drawRouteLine(kakaoVertexes, "KAKAO")
                } else {
                    Log.w("KakaoMapView", "⚠️ Kakao Vertexes are empty")
                }
            } else {
                Log.e("KakaoMapView", "❌ Kakao Vertexes are not a List")
            }

            // 🔍 TMap Vertexes 확인
            val tmapVertexes = args["tmapVertexes"]
            Log.d("KakaoMapView", "🟥 TMap Vertexes (Raw): $tmapVertexes")
            if (tmapVertexes is List<*>) {
                Log.d("KakaoMapView", "🟥 TMap Vertexes Size: ${tmapVertexes.size}")
                if (tmapVertexes.isNotEmpty()) {
                    Log.d("KakaoMapView", "🟥 TMap Vertexes are valid")
                    drawRouteLine(tmapVertexes, "TMAP")
                } else {
                    Log.w("KakaoMapView", "⚠️ TMap Vertexes are empty")
                }
            } else {
                Log.e("KakaoMapView", "❌ TMap Vertexes are not a List")
            }

            // 🔍 Naver Vertexes 확인
            val naverVertexes = args["naverVertexes"]
            Log.d("KakaoMapView", "🟩 Naver Vertexes (Raw): $naverVertexes")
            if (naverVertexes is List<*>) {
                Log.d("KakaoMapView", "🟩 Naver Vertexes Size: ${naverVertexes.size}")
                if (naverVertexes.isNotEmpty()) {
                    Log.d("KakaoMapView", "🟩 Naver Vertexes are valid")
                    drawRouteLine(naverVertexes, "NAVER")
                } else {
                    Log.w("KakaoMapView", "⚠️ Naver Vertexes are empty")
                }
            } else {
                Log.e("KakaoMapView", "❌ Naver Vertexes are not a List")
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

            Log.d("KakaoMapView", "📍 Drawing route line for: $source")
            Log.d("KakaoMapView", "🔍 Vertexes Count: ${vertexes.size}")

            val stylesSet = RouteLineStylesSet.from(
                RouteLineStyles.from(
                    when (source) {
                        "KAKAO" -> RouteLineStyle.from(10f, Color.BLUE)
                        "TMAP" -> RouteLineStyle.from(10f, Color.RED)
                        "NAVER" -> RouteLineStyle.from(10f, Color.GREEN)
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
                    } else {
                        Log.w("KakaoMapView", "⚠️ Invalid vertex format: $vertex")
                        null
                    }
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
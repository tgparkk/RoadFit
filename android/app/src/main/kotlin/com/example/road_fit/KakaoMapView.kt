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

    private var kakaoVertexes: List<*>? = null
    private var tmapVertexes: List<*>? = null
    private var naverVertexes: List<*>? = null

    init {
        currentInstance = this
        initializeMap(args)
    }

    /**
     * 🗺️ Map 초기화
     */
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

    /**
     * 📍 Flutter로부터 전달된 데이터 설정
     */
    private fun setupMap(map: KakaoMap, args: Any?) {
        Log.d("KakaoMapView", "📍 Map Initialization Complete")

        if (args == null || args !is Map<*, *>) {
            Log.e("KakaoMapView", "❌ Invalid arguments passed from Flutter")
            return
        }

        kakaoVertexes = args["kakaoVertexes"] as? List<*>
        tmapVertexes = args["tmapVertexes"] as? List<*>
        naverVertexes = args["naverVertexes"] as? List<*>
        val focusedRoute = args["focusedRoute"] as? String

        Log.d("KakaoMapView", "🟦 Kakao Vertexes: $kakaoVertexes")
        Log.d("KakaoMapView", "🟥 TMap Vertexes: $tmapVertexes")
        Log.d("KakaoMapView", "🟩 Naver Vertexes: $naverVertexes")
        Log.d("KakaoMapView", "🎯 Focused Route: $focusedRoute")

        redrawRouteLines(focusedRoute ?: "")
    }

    /**
     * 📊 Vertex 데이터 업데이트
     */
    fun updateVertexesInternal(kakao: List<*>, tmap: List<*>, naver: List<*>) {
        Log.d("KakaoMapView", "🎯 Internal updating vertexes")
        kakaoVertexes = kakao
        tmapVertexes = tmap
        naverVertexes = naver

        Log.d("KakaoMapView", "🟦 Kakao Vertexes: $kakaoVertexes")
        Log.d("KakaoMapView", "🟥 TMap Vertexes: $tmapVertexes")
        Log.d("KakaoMapView", "🟩 Naver Vertexes: $naverVertexes")

        redrawRouteLines("") // 모든 경로 다시 그리기
    }

    /**
     * 🎯 포커싱된 라인 다시 그리기
     */
    fun redrawFocusedRouteInternal(focusedRoute: String) {
        Log.d("KakaoMapView", "🎯 Internal Redrawing focused route: $focusedRoute")
        redrawRouteLines(focusedRoute)
    }

    /**
     * 🛣️ 모든 라인을 다시 그립니다.
     */
    private fun redrawRouteLines(focusedRoute: String) {
        Log.d("KakaoMapView", "🔄 Starting redrawRouteLines with focusedRoute: $focusedRoute")

        if (routeLineLayer == null) {
            Log.e("KakaoMapView", "❌ RouteLineLayer is null - Cannot draw routes")
            return
        }

        try {
            // 🗑️ 기존 라인 제거
            routeLineLayer?.removeAll()
            Log.d("KakaoMapView", "🗑️ All route lines removed from RouteLineLayer")

            // 🟦 Kakao 경로 그리기
            if (kakaoVertexes != null && kakaoVertexes!!.isNotEmpty()) {
                Log.d("KakaoMapView", "🟦 Kakao Vertexes Exist: true | Size: ${kakaoVertexes!!.size}")
                drawRouteLine(kakaoVertexes!!, Color.BLUE, "KAKAO", focusedRoute == "Kakao")
            } else {
                Log.w("KakaoMapView", "⚠️ Kakao Vertexes are null or empty")
            }

            // 🟥 TMap 경로 그리기
            if (tmapVertexes != null && tmapVertexes!!.isNotEmpty()) {
                Log.d("KakaoMapView", "🟥 TMap Vertexes Exist: true | Size: ${tmapVertexes!!.size}")
                drawRouteLine(tmapVertexes!!, Color.RED, "TMAP", focusedRoute == "TMap")
            } else {
                Log.w("KakaoMapView", "⚠️ TMap Vertexes are null or empty")
            }

            // 🟩 Naver 경로 그리기
            if (naverVertexes != null && naverVertexes!!.isNotEmpty()) {
                Log.d("KakaoMapView", "🟩 Naver Vertexes Exist: true | Size: ${naverVertexes!!.size}")
                drawRouteLine(naverVertexes!!, Color.GREEN, "NAVER", focusedRoute == "Naver")
            } else {
                Log.w("KakaoMapView", "⚠️ Naver Vertexes are null or empty")
            }

            Log.d("KakaoMapView", "✅ Route lines redrawn successfully with focus on: $focusedRoute")
        } catch (e: Exception) {
            Log.e("KakaoMapView", "❌ Error during redrawRouteLines: ${e.localizedMessage}")
        }
    }


    private fun drawRouteLine(vertexes: List<*>, color: Int, source: String, isFocused: Boolean) {
        Log.d("KakaoMapView", "🔹 Drawing route for: $source | Focused: $isFocused")

        if (routeLineLayer == null) {
            Log.e("KakaoMapView", "❌ RouteLineLayer is null. Cannot draw route.")
            return
        }

        if (vertexes.isEmpty()) {
            Log.w("KakaoMapView", "⚠️ Vertex list is empty for $source. Skipping drawing.")
            return
        } else {
            Log.d("KakaoMapView", "✅ Vertex list size: ${vertexes.size}")
        }

        try {
            // 🖌️ 라인 스타일 설정
            val lineWidth = if (isFocused) 15f else 5f
            Log.d("KakaoMapView", "🔹 Line width set to: $lineWidth")

            val style = RouteLineStyle.from(lineWidth, color)
            if (style == null) {
                Log.e("KakaoMapView", "❌ Failed to create RouteLineStyle for $source")
                return
            }

            val styles = RouteLineStyles.from(style)
            if (styles == null) {
                Log.e("KakaoMapView", "❌ Failed to create RouteLineStyles for $source")
                return
            }

            val stylesSet = RouteLineStylesSet.from(styles)
            if (stylesSet == null) {
                Log.e("KakaoMapView", "❌ Failed to create RouteLineStylesSet for $source")
                return
            }

            Log.d("KakaoMapView", "✅ RouteLineStylesSet created successfully for $source")

            // 🛣️ 경로 세그먼트 생성
            val segment = RouteLineSegment.from(
                vertexes.mapIndexedNotNull { index, vertex ->
                    if (vertex is List<*> && vertex.size == 2) {
                        val x = (vertex[0] as? Number)?.toDouble()
                        val y = (vertex[1] as? Number)?.toDouble()
                        if (x != null && y != null) {
                            Log.d("KakaoMapView", "🟢 Vertex[$index]: x=$x, y=$y")
                            LatLng.from(y, x)
                        } else {
                            Log.w("KakaoMapView", "⚠️ Invalid vertex format at index $index: $vertex")
                            null
                        }
                    } else {
                        Log.w("KakaoMapView", "⚠️ Unexpected vertex format at index $index: $vertex")
                        null
                    }
                }
            ).setStyles(stylesSet.getStyles(0))

            if (segment == null || segment.points.isEmpty()) {
                Log.e("KakaoMapView", "❌ RouteLineSegment is null or empty for $source")
                return
            }

            Log.d("KakaoMapView", "✅ RouteLineSegment created with ${segment.points.size} points for $source")

            // 🚀 RouteLineOptions 설정
            val options = RouteLineOptions.from(listOf(segment))
                .setStylesSet(stylesSet)

            if (options == null) {
                Log.e("KakaoMapView", "❌ RouteLineOptions creation failed for $source")
                return
            }

            // 🛣️ 라인 그리기
            routeLineLayer?.addRouteLine(options)
            Log.d("KakaoMapView", "✅ RouteLine added successfully for source: $source with style: ${if (isFocused) "focused" else "default"}")

        } catch (e: Exception) {
            Log.e("KakaoMapView", "❌ Exception in drawRouteLine for $source: ${e.localizedMessage}")
        }
    }


    override fun getView(): View = mapView

    override fun dispose() {
        mapView.finish()
        Log.d("KakaoMapView", "✅ MapView Finished")
    }

    companion object {
        var currentInstance: KakaoMapView? = null

        fun updateVertexes(kakao: List<*>, tmap: List<*>, naver: List<*>) {
            currentInstance?.updateVertexesInternal(kakao, tmap, naver)
        }

        fun redrawFocusedRoute(focusedRoute: String) {
            currentInstance?.redrawFocusedRouteInternal(focusedRoute)
        }
    }
}

package com.example.acela

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

import android.webkit.WebView
import android.webkit.WebViewClient
import android.content.Context
import com.google.gson.Gson

import android.annotation.TargetApi
import android.app.Activity
import android.content.pm.ApplicationInfo
import android.graphics.Bitmap
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.View
import android.webkit.JavascriptInterface
import android.webkit.WebResourceRequest
import android.widget.FrameLayout
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import android.net.Uri
import android.util.Log
import android.webkit.WebResourceResponse
import androidx.webkit.WebViewAssetLoader

class MainActivity: FlutterActivity() {
    var webView: WebView? = null
    // var assetLoader: WebViewAssetLoader? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        if (webView == null) {
            setupView()
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "channel").setMethodCallHandler {
                call, result ->
            // Note: this method is invoked on the main thread.
            // TODO
        }
    }

    fun setupView() {
        val params = FrameLayout.LayoutParams(0, 0)
        webView = WebView(activity)
        val decorView = activity.window.decorView as FrameLayout
        decorView.addView(webView, params)
        webView?.visibility = View.GONE
        webView?.settings?.javaScriptEnabled = true
        webView?.settings?.domStorageEnabled = true
        webView?.settings?.allowFileAccessFromFileURLs = true
        WebView.setWebContentsDebuggingEnabled(true)
        var assetLoader = WebViewAssetLoader.Builder()
            .addPathHandler("/assets/", WebViewAssetLoader.AssetsPathHandler(this))
            .build()
        val client: WebViewClient = object: WebViewClient() {
            override fun shouldInterceptRequest(
                view: WebView,
                request: WebResourceRequest
            ): WebResourceResponse? {
                return assetLoader.shouldInterceptRequest(request.url)
            }

            override fun shouldInterceptRequest(
                view: WebView,
                url: String
            ): WebResourceResponse? {
                return assetLoader.shouldInterceptRequest(Uri.parse(url))
            }
        }
        webView?.webViewClient = client
        webView?.addJavascriptInterface(WebAppInterface(this), "Android")
        webView?.loadUrl("https://appassets.androidplatform.net/assets/index.html")
    }
}

class WebAppInterface(private val mContext: Context) {
    @JavascriptInterface
    fun postMessage(message: String) {
        val gson = Gson()
        val dataObject = gson.fromJson(message, JSEvent::class.java)
        when (dataObject.type) {
            JSBridgeAction.GET_SERVERS.value -> {
                // now respond back to flutter
            }
        }
    }
}

data class JSEvent (
    val type: String,
)

enum class JSBridgeAction(val value: String) {
    GET_SERVERS("GetDRAppCloudServers"),
}

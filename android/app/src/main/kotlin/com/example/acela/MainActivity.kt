package com.example.acela

import android.annotation.SuppressLint
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
import android.webkit.ValueCallback
import android.webkit.WebResourceResponse
import androidx.annotation.RequiresApi
import androidx.webkit.WebViewAssetLoader

class MainActivity: FlutterActivity() {
    var webView: WebView? = null
    var result: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        if (webView == null) {
            setupView()
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.acela/auth").setMethodCallHandler {
                call, result ->
            this.result = result
            val username = call.argument<String>("username")
            val postingKey = call.argument<String>("postingKey")
            val encryptedToken = call.argument<String>("encryptedToken")
            if (call.method == "validate" && username != null && postingKey != null) {
                webView?.evaluateJavascript("validateHiveKey('$username','$postingKey');", null)
            } else if (call.method == "encryptedToken" && username != null && postingKey != null && encryptedToken != null) {
                webView?.evaluateJavascript("decryptMemo('$username','$postingKey', '$encryptedToken');", null)
            }
        }
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun setupView() {
        val params = FrameLayout.LayoutParams(0, 0)
        webView = WebView(activity)
        val decorView = activity.window.decorView as FrameLayout
        decorView.addView(webView, params)
        webView?.visibility = View.GONE
        webView?.settings?.javaScriptEnabled = true
        webView?.settings?.domStorageEnabled = true
        WebView.setWebContentsDebuggingEnabled(true)
        val assetLoader = WebViewAssetLoader.Builder()
            .addPathHandler("/assets/", WebViewAssetLoader.AssetsPathHandler(this))
            .build()
        val client: WebViewClient = object: WebViewClient() {
            @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
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
        var main = mContext as? MainActivity ?: return
        val gson = Gson()
        val dataObject = gson.fromJson(message, JSEvent::class.java)
        when (dataObject.type) {
            JSBridgeAction.VALIDATE_HIVE_KEY.value -> {
                // now respond back to flutter
                main.result?.success(message)
            }
            JSBridgeAction.DECRYPTED_MEMO.value -> {
                main.result?.success(message)
            }
        }
    }
}

data class JSEvent (
    val type: String,
)

enum class JSBridgeAction(val value: String) {
    VALIDATE_HIVE_KEY("validateHiveKey"),
    DECRYPTED_MEMO("decryptedMemo"),
}

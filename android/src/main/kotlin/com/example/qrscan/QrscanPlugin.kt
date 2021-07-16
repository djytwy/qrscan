package com.example.qrscan

import android.src.main.kotlin.com.example.qrscan.ScanErrorCode
import android.src.main.kotlin.com.example.qrscan.ScanViewFactory
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** QrscanPlugin */
class QrscanPlugin : FlutterPlugin, ActivityAware, MethodCallHandler, QrCodeResultCallback {

    private val TAG: String = "QrscanPlugin"


    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var eventPermissionChannel: EventChannel

    private var eventSink: EventChannel.EventSink? = null
    private var eventPermissionsSink: EventChannel.EventSink? = null
    private var scanViewFactory: ScanViewFactory? = null


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        scanViewFactory = ScanViewFactory(this)
        flutterPluginBinding
                .platformViewRegistry
                .registerViewFactory(
                        "ScanView",
                        scanViewFactory)


        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "io.isa.flutter.plugin.qrscan.channel")
        channel.setMethodCallHandler(this)


        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "io.isa.flutter.plugin.qrscan.sink");
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                this@QrscanPlugin.eventSink = events
            }

            override fun onCancel(arguments: Any?) {
            }
        })

        eventPermissionChannel = EventChannel(flutterPluginBinding.binaryMessenger, "io.isa.flutter.plugin.qrscan.permission.sink");
        eventPermissionChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                this@QrscanPlugin.eventPermissionsSink = events
            }

            override fun onCancel(arguments: Any?) {
            }
        })
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "close") {
            scanViewFactory?.close()
        } else if (call.method == "resume") {
            scanViewFactory?.resume()
        } else if (call.method == "switchFlashlight") {
            call.argument<Boolean>("switchFlashlight")?.let { scanViewFactory?.switchFlashlight(it) }
        }  else if (call.method == "scanImagePath") {
            call.argument<String>("path")?.let { scanViewFactory?.scanImagePath(it) }
        } else if (call.method == "pause") {
            scanViewFactory?.pause()
        } else {
            result.notImplemented()
        }
    }


    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        eventSink?.endOfStream()
        eventChannel?.setStreamHandler(null)
        eventPermissionsSink?.endOfStream()
        eventPermissionChannel?.setStreamHandler(null)
        scanViewFactory?.close()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        scanViewFactory?.setActivity(binding)
    }


    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
        scanViewFactory?.close()
    }

    override fun barcodeResult(result: String?) {
        eventSink?.success(result)
    }

    override fun permission(result: ScanErrorCode?) {
        eventPermissionsSink?.success(result?.code)
    }

}

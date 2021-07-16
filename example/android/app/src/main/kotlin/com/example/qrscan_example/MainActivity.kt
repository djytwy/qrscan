package com.example.qrscan_example

import android.content.res.Configuration
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity: FlutterActivity() {

    private val CHARGING_CHANNEL = "io.isa.flutter.plugin.onConfigurationChanged.sink"
    private var events: EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHARGING_CHANNEL).setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any, events: EventSink) {
                        this@MainActivity.events = events
                    }

                    override fun onCancel(arguments: Any) {}
                }
        )
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        if (events != null) {
            events!!.success("onConfigurationChanged")
        }
    }
}

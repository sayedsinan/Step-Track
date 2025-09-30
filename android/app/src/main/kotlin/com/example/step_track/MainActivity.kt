package com.example.step_track

import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "health_connect_events"
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                // TODO: Register Health Connect Passive Listener
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    private fun sendStepEvent(ts: Long, count: Int) {
        eventSink?.success(mapOf("type" to "step", "ts" to ts, "count" to count))
    }

    private fun sendHREvent(ts: Long, bpm: Int) {
        eventSink?.success(mapOf("type" to "hr", "ts" to ts, "bpm" to bpm))
    }
}

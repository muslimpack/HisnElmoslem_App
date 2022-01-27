package com.hassaneltantawy.hisnelmoslem

import io.flutter.embedding.android.FlutterActivity
import android.view.KeyEvent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
            private lateinit var channel : MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "volume_button_channel")
    }
    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
    
        return when (event.keyCode) {
            KeyEvent.KEYCODE_VOLUME_DOWN -> {
                channel.invokeMethod("volumeBtnPressed", "volume_down")

                // Do your thing
                return true
            }
            KeyEvent.KEYCODE_VOLUME_UP -> {
                channel.invokeMethod("volumeBtnPressed", "volume_up")
                return true
            }
            else -> super.dispatchKeyEvent(event)
        }
    }
}
